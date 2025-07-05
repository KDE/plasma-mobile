/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <KAuth/ActionReply>
#include <KAuth/HelperSupport>

#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QObject>
#include <qloggingcategory.h>
#include <qprocess.h>

using namespace Qt::StringLiterals;

#define WAYDROID_COMMAND "waydroid"

class WaydroidHelper : public QObject
{
    Q_OBJECT
public Q_SLOTS:
    KAuth::ActionReply initialize(const QVariantMap &args);
};

KAuth::ActionReply WaydroidHelper::initialize(const QVariantMap &args)
{
    QString systemType = args.value(u"systemType"_s).toString();
    QString romType = args.value(u"romType"_s).toString();
    bool forced = args.value(u"forced"_s, false).toBool();

    QStringList arguments;
    arguments << "init";
    arguments << "-s" << systemType;
    arguments << "-r" << romType;
    if (forced) {
        arguments << "-f";
    }

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    if (process->exitCode() == 0) {
        return KAuth::ActionReply::SuccessReply();
    } else {
        qWarning() << "Failed to initialize Waydroid: " << process->readAllStandardError();
        return KAuth::ActionReply::HelperErrorReply();
    }
}

KAUTH_HELPER_MAIN("org.kde.plasma.mobileshell.waydroidhelper", WaydroidHelper)

#include "waydroidhelper.moc"