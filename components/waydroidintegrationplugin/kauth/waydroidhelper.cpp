/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "waydroidhelper_debug.h"

#include <KAuth/ActionReply>
#include <KAuth/HelperSupport>

#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QLoggingCategory>
#include <QObject>
#include <QProcess>
#include <QRegularExpression>

using namespace Qt::StringLiterals;

#define WAYDROID_COMMAND "waydroid"

// Extract current downloaded size, total_size and speed.
// Example of log: "[Downloading]   62.19 MB/1197.24 MB    96740.75 kbps(approx.)"
static const QRegularExpression downloadingStatusRegExp(R"(\[Downloading]\s*(\d+\.\d+)\s*MB/(\d+\.\d+)\s*MB\s*(\d+\.\d+)\s*kbps\(approx\.\))");

class WaydroidHelper : public QObject
{
    Q_OBJECT
public Q_SLOTS:
    KAuth::ActionReply initialize(const QVariantMap &args);
    KAuth::ActionReply getandroidid(const QVariantMap &args);
};

KAuth::ActionReply WaydroidHelper::initialize(const QVariantMap &args)
{
    const QString systemType = args.value("systemType"_L1).toString();
    const QString romType = args.value("romType"_L1).toString();
    const bool forced = args.value("forced"_L1, false).toBool();

    QStringList arguments{u"init"_s, u"-s"_s, systemType, u"-r"_s, romType};
    if (forced) {
        arguments << "-f";
    }

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);

    connect(process, &QProcess::readyReadStandardOutput, this, [process]() {
        const QByteArray output = process->readAllStandardOutput();
        const QByteArray lastLine = output.split('\r').last();

        QVariantMap informations = {{u"log"_s, lastLine.constData()}};

        QRegularExpressionMatch match = downloadingStatusRegExp.match(lastLine);
        if (!match.hasMatch()) {
            KAuth::HelperSupport::progressStep(informations);
            return;
        }

        const QString downloadMatch = match.captured(1);
        const QString totalMatch = match.captured(2);
        const QString speedMatch = match.captured(3);
        if (downloadMatch.isEmpty() || totalMatch.isEmpty() || speedMatch.isEmpty()) {
            KAuth::HelperSupport::progressStep(informations);
            return;
        }

        bool downloadCastOk, totalCastOk, speedCastOk;
        float downloadedMB = downloadMatch.toFloat(&downloadCastOk);
        float totalMB = totalMatch.toFloat(&totalCastOk);
        float speedKbps = speedMatch.toFloat(&speedCastOk);

        if (downloadCastOk && totalCastOk && speedCastOk) {
            informations.insert(u"downloaded"_s, downloadedMB);
            informations.insert(u"total"_s, totalMB);
            informations.insert(u"speed"_s, speedKbps);
        }

        KAuth::HelperSupport::progressStep(informations);
    });

    process->waitForFinished(-1);

    if (process->exitCode() == 0) {
        return KAuth::ActionReply::SuccessReply();
    } else {
        QByteArray errorData = process->readAllStandardError();
        QString errorString = QString::fromUtf8(errorData);

        qCWarning(WAYDROIDHELPER) << "Failed to initialize Waydroid: " << errorString;

        KAuth::ActionReply reply = KAuth::ActionReply::HelperErrorReply();
        reply.setErrorDescription(errorString);
        return reply;
    }
}

KAuth::ActionReply WaydroidHelper::getandroidid(const QVariantMap &args)
{
    Q_UNUSED(args);

    QStringList arguments = {u"shell"_s,
                             u"sqlite3"_s,
                             u"/data/data/com.google.android.gsf/databases/gservices.db"_s,
                             u"select value from main where name = \"android_id\""_s};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();
    const QString androidId = process->readAllStandardOutput().trimmed();

    if (process->exitCode() == 0) {
        KAuth::ActionReply reply;
        reply.addData("android_id"_L1, androidId);
        return reply;
    } else {
        qCWarning(WAYDROIDHELPER) << "Failed to get Android ID: " << process->readAllStandardError();
        return KAuth::ActionReply::HelperErrorReply();
    }
}

KAUTH_HELPER_MAIN("org.kde.plasma.mobileshell.waydroidhelper", WaydroidHelper)

#include "waydroidhelper.moc"