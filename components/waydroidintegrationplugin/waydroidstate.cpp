/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "waydroidstate.h"
#include "waydroidintegrationplugin_debug.h"

#include <QClipboard>
#include <QDebug>
#include <QGuiApplication>
#include <QProcess>
#include <QRegularExpression>
#include <QTimer>
#include <QtLogging>

#include <KAuth/Action>
#include <KAuth/ExecuteJob>
#include <KLocalizedString>

using namespace Qt::StringLiterals;

#define WAYDROID_COMMAND "waydroid"
#define MULTI_WINDOWS_PROP_KEY "persist.waydroid.multi_windows"
#define SUSPEND_PROP_KEY "persist.waydroid.suspend"
#define UEVENT_PROP_KEY "persist.waydroid.uevent"

static const QRegularExpression sessionRegExp(u"Session:\\s*(\\w+)"_s);
static const QRegularExpression ipAdressRegExp(u"IP address:\\s*(\\d+\\.\\d+\\.\\d+\\.\\d+)"_s);

WaydroidState::WaydroidState(QObject *parent)
    : QObject{parent}
{
    // Connect it-self to auto-refresh when required status has changed
    connect(this, &WaydroidState::statusChanged, this, &WaydroidState::refreshSessionInfo);
    connect(this, &WaydroidState::sessionStatusChanged, this, &WaydroidState::refreshPropsInfo);

    refreshSupportsInfo();
}

void WaydroidState::refreshSupportsInfo()
{
    const QStringList arguments{u"-h"_s};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    const int exitCode = process->exitCode();
    if (exitCode != 0) {
        m_status = NotSupported;
        Q_EMIT statusChanged();
        return;
    }

    const QString output = fetchSessionInfo();
    if (!output.contains("WayDroid is not initialized")) {
        m_status = Initialized;
    } else {
        m_status = NotInitialized;
    }
    Q_EMIT statusChanged();
}

void WaydroidState::refreshSessionInfo()
{
    if (m_status != Initialized) {
        return;
    }

    const QString output = fetchSessionInfo();

    const QString sessionMatchResult = extractRegExp(output, sessionRegExp);
    WaydroidState::SessionStatus newSessionStatus;

    if (!sessionMatchResult.isEmpty()) {
        newSessionStatus = sessionMatchResult.contains("RUNNING") ? SessionRunning : SessionStopped;
    } else {
        newSessionStatus = SessionStopped;
    }

    if (m_sessionStatus != newSessionStatus) {
        m_sessionStatus = newSessionStatus;
        Q_EMIT sessionStatusChanged();
    }

    m_ipAddress = extractRegExp(output, ipAdressRegExp);
    Q_EMIT ipAddressChanged();
}

void WaydroidState::refreshPropsInfo()
{
    if (m_sessionStatus != SessionRunning) {
        return;
    }

    const QString multiWindowsPropValue = fetchPropValue(MULTI_WINDOWS_PROP_KEY, "false");
    m_multiWindows = multiWindowsPropValue == "true";
    Q_EMIT multiWindowsChanged();

    const QString suspendPropValue = fetchPropValue(SUSPEND_PROP_KEY, "true");
    m_suspend = suspendPropValue == "true";
    Q_EMIT suspendChanged();

    const QString ueventPropValue = fetchPropValue(UEVENT_PROP_KEY, "false");
    m_uevent = ueventPropValue == "true";
    Q_EMIT ueventChanged();
}

void WaydroidState::resetError()
{
    m_errorTitle = "";
    Q_EMIT errorTitleChanged();

    if (m_errorMessage != "") {
        m_errorMessage = "";
        Q_EMIT errorMessageChanged();
    }
}

void WaydroidState::initialize(const SystemType systemType, const RomType romType, const bool forced)
{
    if (m_status == Initializing) {
        return;
    }

    m_status = Initializing;
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

    const QVariantMap args = {{u"systemType"_s, systemTypeArg}, {u"romType"_s, romTypeArg}, {u"forced"_s, forced}};

    KAuth::Action writeAction(u"org.kde.plasma.mobileshell.waydroidhelper.initialize"_s);
    writeAction.setHelperId(u"org.kde.plasma.mobileshell.waydroidhelper"_s);
    writeAction.setArguments(args);
    writeAction.setTimeout(3600000); // HACK: 1 hour to wait installation

    KAuth::ExecuteJob *job = writeAction.execute();
    job->start();

    connect(job, &KAuth::ExecuteJob::finished, this, [this](KJob *job, auto) {
        if (job->error() == 0) {
            m_status = Initialized;
        } else {
            m_errorTitle = i18n("Failed to initialize Waydroid.");
            Q_EMIT errorTitleChanged();
            m_errorMessage = job->errorString();
            Q_EMIT errorMessageChanged();

            m_status = NotInitialized;
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "KAuth returned an error code:" << job->error() << " message: " << job->errorString();
        }

        Q_EMIT statusChanged();
    });
}

void WaydroidState::startSession()
{
    if (m_sessionStatus == SessionStarting || m_sessionStatus == SessionRunning) {
        return;
    }

    m_sessionStatus = SessionStarting;
    Q_EMIT sessionStatusChanged();

    const QStringList arguments{u"session"_s, u"start"_s};

    // Don't wait for result because the command is blocking
    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);

    connect(process, &QProcess::finished, this, [this, process](int exitCode, QProcess::ExitStatus exitStatus) {
        Q_UNUSED(exitStatus);

        if (exitCode == 0) {
            return;
        }

        m_sessionStatus = SessionStopped;
        Q_EMIT sessionStatusChanged();

        QByteArray errorData = process->readAllStandardError();
        QString errorString = QString::fromUtf8(errorData);

        m_errorTitle = i18n("Failed to start the Waydroid session.");
        Q_EMIT errorTitleChanged();
        m_errorMessage = errorString;
        Q_EMIT errorMessageChanged();

        qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to start the Waydroid session: " << errorString;
    });

    checkSessionStarting(10);
}

void WaydroidState::stopSession()
{
    if (m_sessionStatus == SessionStopped) {
        return;
    }

    const QStringList arguments{u"session"_s, u"stop"_s};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    if (process->exitCode() == 0) {
        m_sessionStatus = SessionStopped;
        Q_EMIT sessionStatusChanged();
    } else {
        qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to stop the Waydroid session: " << process->readAllStandardError();
    }
}

void WaydroidState::copyToClipboard(const QString text)
{
    qGuiApp->clipboard()->setText(text);
}

WaydroidState::Status WaydroidState::status() const
{
    return m_status;
}

WaydroidState::SessionStatus WaydroidState::sessionStatus() const
{
    return m_sessionStatus;
}

QString WaydroidState::ipAddress() const
{
    return m_ipAddress;
}

QString WaydroidState::errorTitle() const
{
    return m_errorTitle;
}

QString WaydroidState::errorMessage() const
{
    return m_errorMessage;
}

bool WaydroidState::multiWindows() const
{
    return m_multiWindows;
}

void WaydroidState::setMultiWindows(const bool multiWindows)
{
    if (m_multiWindows == multiWindows) {
        return;
    }

    const QString value = multiWindows ? "true" : "false";

    if (writePropValue(MULTI_WINDOWS_PROP_KEY, value)) {
        m_multiWindows = multiWindows;
        Q_EMIT multiWindowsChanged();
    }
}

bool WaydroidState::suspend() const
{
    return m_suspend;
}

void WaydroidState::setSuspend(const bool suspend)
{
    if (m_suspend == suspend) {
        return;
    }

    const QString value = suspend ? "true" : "false";

    if (writePropValue(SUSPEND_PROP_KEY, value)) {
        m_suspend = suspend;
        Q_EMIT suspendChanged();
    }
}

bool WaydroidState::uevent() const
{
    return m_uevent;
}

void WaydroidState::setUevent(const bool uevent)
{
    if (m_uevent == uevent) {
        return;
    }

    const QString value = uevent ? "true" : "false";

    if (writePropValue(UEVENT_PROP_KEY, value)) {
        m_uevent = uevent;
        Q_EMIT ueventChanged();
    }
}

QString WaydroidState::fetchSessionInfo()
{
    const QStringList arguments{u"status"_s};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    return process->readAllStandardOutput();
}

QString WaydroidState::fetchPropValue(const QString key, const QString defaultValue)
{
    const QStringList arguments{u"prop"_s, u"get"_s, key};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    const QString commandOutput = process->readAllStandardOutput();
    const QString value = commandOutput.split("\n").first().trimmed();

    if (value.isEmpty()) {
        return defaultValue;
    }

    return value;
}

bool WaydroidState::writePropValue(const QString key, const QString value)
{
    const QStringList arguments{u"prop"_s, u"set"_s, key, value};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);
    process->waitForFinished();

    return process->exitCode() == 0;
}

QString WaydroidState::extractRegExp(const QString text, const QRegularExpression regExp) const
{
    const QRegularExpressionMatch match = regExp.match(text);

    if (match.hasMatch() && match.lastCapturedIndex() > 0) {
        return match.captured(match.lastCapturedIndex());
    } else {
        return "";
    }
}

void WaydroidState::checkSessionStarting(const int limit, const int tried)
{
    if (m_sessionStatus != SessionStarting) {
        return;
    }

    const QString output = fetchSessionInfo();
    const QString sessionMatchResult = extractRegExp(output, sessionRegExp);

    if (sessionMatchResult.contains("RUNNING")) {
        m_sessionStatus = SessionRunning;
        Q_EMIT sessionStatusChanged();
    } else if (tried == limit) {
        m_sessionStatus = SessionStopped;
        Q_EMIT sessionStatusChanged();
        qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to start the session after " << tried << " tries";
    } else {
        QTimer::singleShot(500, [this, tried, limit]() {
            checkSessionStarting(limit, tried + 1);
        });
    }
}
