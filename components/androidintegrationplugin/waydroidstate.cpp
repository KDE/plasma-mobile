/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "waydroidstate.h"
#include <qdebug.h>
#include <qprocess.h>

#include <KAuth/Action>
#include <KAuth/ExecuteJob>

using namespace Qt::StringLiterals;

#define WAYDROID_COMMAND "waydroid"

WaydroidState::WaydroidState(QObject *parent)
    : QObject{parent}
{
    checkSupports();
}

void WaydroidState::checkSupports()
{
    int exitCode = QProcess::execute(WAYDROID_COMMAND);
    if (exitCode != 0) {
        m_status = WaydroidState::Status::NotSupported;
        Q_EMIT statusChanged();
    }

    QStringList arguments;
    arguments << "status";

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    const QString output = process->readAllStandardOutput();

    if (!output.contains("WayDroid is not initialized")) {
        m_status = WaydroidState::Status::Initialized;
    } else {
        m_status = WaydroidState::Status::NotInitialized;
    }
    Q_EMIT statusChanged();
}

void WaydroidState::initialize(const SystemType systemType, const RomType romType, const bool forced)
{
    if (m_status == WaydroidState::Status::Initialiazing) {
        return;
    }

    m_status = WaydroidState::Status::Initialiazing;
    Q_EMIT statusChanged();

    QString systemTypeArg;
    switch (systemType) {
    case SystemType::Vanilla:
        systemTypeArg = "VANILLA";
        break;
    case SystemType::Foss:
        systemTypeArg = "FOSS";
        break;
    case SystemType::Gapps:
        systemTypeArg = "GAPPS";
        break;
    }

    QString romTypeArg;
    switch (romType) {
    case RomType::Lineage:
        romTypeArg = "lineage";
        break;
    case RomType::Bliss:
        romTypeArg = "bliss";
        break;
    }

    QVariantMap args = {{u"systemType"_s, systemTypeArg}, {u"romType"_s, romTypeArg}, {u"forced"_s, forced}};

    KAuth::Action writeAction(u"org.kde.plasma.mobileshell.waydroidhelper.initialize"_s);
    writeAction.setHelperId(u"org.kde.plasma.mobileshell.waydroidhelper"_s);
    writeAction.setArguments(args);
    writeAction.setTimeout(3600000); // HACK: 1 hour to wait installation

    KAuth::ExecuteJob *job = writeAction.execute();
    if (job->exec()) {
        m_status = WaydroidState::Status::Initialized;
    } else {
        m_status = WaydroidState::Status::FailedToInitialize;
        qWarning() << "KAuth returned an error code:" << job->error() << " message: " << job->errorString();
    }

    Q_EMIT statusChanged();
}

void WaydroidState::startSession()
{
    QStringList arguments;
    arguments << "session" << "start";

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    if (process->exitCode() == 0) {
        m_sessionRunning = true;
        Q_EMIT sessionRunningChanged();
    } else {
        qWarning() << "Failed to start the Waydroid session: " << process->readAllStandardError();
    }
}

void WaydroidState::stopSession()
{
    QStringList arguments;
    arguments << "session" << "stop";

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    if (process->exitCode() == 0) {
        m_sessionRunning = false;
        Q_EMIT sessionRunningChanged();
    } else {
        qWarning() << "Failed to stop the Waydroid session: " << process->readAllStandardError();
    }
}

WaydroidState::Status WaydroidState::status() const
{
    return m_status;
}

bool WaydroidState::sessionRunning() const
{
    return m_sessionRunning;
}