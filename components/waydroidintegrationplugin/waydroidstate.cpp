/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "waydroidstate.h"
#include "waydroidintegrationplugin_debug.h"
#include "waydroidshared.h"

#include <QClipboard>
#include <QCoroProcess>
#include <QDebug>
#include <QDir>
#include <QGuiApplication>
#include <QProcess>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QTimer>
#include <QtLogging>

#include <KAuth/Action>
#include <KAuth/ExecuteJob>
#include <KConfigGroup>
#include <KDesktopFile>
#include <KLocalizedString>
#include <KSandbox>

using namespace Qt::StringLiterals;

#define MULTI_WINDOWS_PROP_KEY "persist.waydroid.multi_windows"
#define SUSPEND_PROP_KEY "persist.waydroid.suspend"
#define UEVENT_PROP_KEY "persist.waydroid.uevent"

static const QRegularExpression sessionRegExp(u"Session:\\s*(\\w+)"_s);
static const QRegularExpression ipAdressRegExp(u"IP address:\\s*(\\d+\\.\\d+\\.\\d+\\.\\d+)"_s);
static const QRegularExpression systemOtaRegExp(u"system_ota\\s*=\\s*(\\S+)"_s);

WaydroidState::WaydroidState(QObject *parent)
    : QObject{parent}
    , m_applicationListModel{new WaydroidApplicationListModel{this}}
{
    // Connect it-self to auto-refresh when required status has changed
    connect(this, &WaydroidState::statusChanged, this, &WaydroidState::refreshSessionInfo);
    connect(this, &WaydroidState::statusChanged, this, &WaydroidState::refreshInstallationInfo);
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

void WaydroidState::refreshInstallationInfo()
{
    if (m_status != Initialized) {
        return;
    }

    QFile file("/var/lib/waydroid/waydroid.cfg");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return;
    }

    QTextStream in(&file);
    const QString fileContent = in.readAll();

    const QString systemMatch = extractRegExp(fileContent, systemOtaRegExp);
    if (systemMatch.contains("vanilla", Qt::CaseInsensitive)) {
        m_systemType = Vanilla;
    } else if (systemMatch.contains("gapps", Qt::CaseInsensitive)) {
        m_systemType = Gapps;
    } else if (systemMatch.contains("foss", Qt::CaseInsensitive)) {
        m_systemType = Foss;
    } else {
        m_systemType = UnknownSystemType;
    }
    Q_EMIT systemTypeChanged();
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

void WaydroidState::refreshAndroidId()
{
    if (m_status != Initialized) {
        return;
    }

    KAuth::Action writeAction(u"org.kde.plasma.mobileshell.waydroidhelper.getandroidid"_s);
    writeAction.setHelperId(u"org.kde.plasma.mobileshell.waydroidhelper"_s);

    KAuth::ExecuteJob *job = writeAction.execute();
    job->start();

    connect(job, &KAuth::ExecuteJob::finished, this, [this](KJob *job, auto) {
        KAuth::ExecuteJob *executeJob = dynamic_cast<KAuth::ExecuteJob *>(job);
        if (executeJob->error() == 0) {
            m_androidId = executeJob->data()["android_id"].toString();
        } else {
            m_androidId = "";
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "KAuth returned an error code:" << executeJob->error();
        }

        Q_EMIT androidIdChanged();
    });
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

QCoro::QmlTask WaydroidState::initializeQml(const SystemType systemType, const RomType romType, const bool forced)
{
    return initialize(systemType, romType, forced);
}

QCoro::Task<void> WaydroidState::initialize(const SystemType systemType, const RomType romType, const bool forced)
{
    if (m_status == Initializing) {
        co_return;
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
    default:
        systemTypeArg = "VANILLA";
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

    connect(job, &KAuth::ExecuteJob::newData, this, [this](const QVariantMap &data) {
        QString log = data.value("log", "").toString();
        float downloaded = data.value("downloaded", 0.0).toFloat();
        float total = data.value("total", 0.0).toFloat();
        float speed = data.value("speed", 0.0).toFloat();

        qCDebug(WAYDROIDINTEGRATIONPLUGIN) << "log: " << log;
        Q_EMIT downloadStatusChanged(downloaded, total, speed);
    });

    co_await qCoro(job, &KAuth::ExecuteJob::finished);

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
}

QCoro::QmlTask WaydroidState::startSessionQml()
{
    return startSession();
}

QCoro::Task<void> WaydroidState::startSession()
{
    if (m_sessionStatus == SessionStarting || m_sessionStatus == SessionRunning) {
        co_return;
    }

    m_sessionStatus = SessionStarting;
    Q_EMIT sessionStatusChanged();

    const QStringList arguments{u"session"_s, u"start"_s};

    QProcess *basicProcess = new QProcess(this);
    auto process = qCoro(basicProcess);
    co_await process.start(WAYDROID_COMMAND, arguments);

    connect(basicProcess, &QProcess::finished, this, [this, basicProcess](int exitCode, QProcess::ExitStatus exitStatus) {
        Q_UNUSED(exitStatus);

        if (exitCode == 0) {
            return;
        }

        m_sessionStatus = SessionStopped;
        Q_EMIT sessionStatusChanged();

        QByteArray errorData = basicProcess->readAllStandardError();
        QString errorString = QString::fromUtf8(errorData);

        m_errorTitle = i18n("Failed to start the Waydroid session.");
        Q_EMIT errorTitleChanged();
        m_errorMessage = errorString;
        Q_EMIT errorMessageChanged();

        qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to start the Waydroid session: " << errorString;
    });

    checkSessionStarting(10);
}

QCoro::QmlTask WaydroidState::stopSessionQml()
{
    return stopSession();
}

QCoro::Task<void> WaydroidState::stopSession()
{
    if (m_sessionStatus == SessionStopped) {
        co_return;
    }

    const QStringList arguments{u"session"_s, u"stop"_s};

    QProcess basicProcess = QProcess(this);
    auto process = qCoro(basicProcess);
    co_await process.start(WAYDROID_COMMAND, arguments);
    co_await process.waitForFinished();

    if (basicProcess.exitCode() == 0) {
        m_sessionStatus = SessionStopped;
        Q_EMIT sessionStatusChanged();
    } else {
        qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to stop the Waydroid session: " << basicProcess.readAllStandardError();
    }
}

void WaydroidState::copyToClipboard(const QString text)
{
    qGuiApp->clipboard()->setText(text);
}

QCoro::QmlTask WaydroidState::resetWaydroidQml()
{
    return resetWaydroid();
}

QCoro::Task<void> WaydroidState::resetWaydroid()
{
    if (m_status != Initialized || m_sessionStatus == SessionStarting) {
        co_return;
    }

    m_status = Resetting;
    Q_EMIT statusChanged();

    if (m_sessionStatus == SessionRunning) {
        co_await stopSession();
    }

    const QVariantMap args = {{u"homeDir"_s, QDir::homePath()}};

    KAuth::Action writeAction(u"org.kde.plasma.mobileshell.waydroidhelper.reset"_s);
    writeAction.setHelperId(u"org.kde.plasma.mobileshell.waydroidhelper"_s);
    writeAction.setArguments(args);

    KAuth::ExecuteJob *job = writeAction.execute();
    job->start();

    co_await qCoro(job, &KAuth::ExecuteJob::finished);

    removeWaydroidApplications();

    if (job->error() == 0) {
        m_status = NotInitialized;
    } else {
        m_errorTitle = i18n("Failed to reset Waydroid.");
        Q_EMIT errorTitleChanged();

        m_status = Initialized;
        qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "KAuth returned an error code:" << job->error() << " message: " << job->errorString();
    }

    Q_EMIT statusChanged();
}

WaydroidState::Status WaydroidState::status() const
{
    return m_status;
}

WaydroidState::SessionStatus WaydroidState::sessionStatus() const
{
    return m_sessionStatus;
}

WaydroidState::SystemType WaydroidState::systemType() const
{
    return m_systemType;
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

QString WaydroidState::androidId() const
{
    return m_androidId;
}

WaydroidApplicationListModel *WaydroidState::applicationListModel() const
{
    return m_applicationListModel;
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

QString WaydroidState::desktopFileDirectory()
{
    auto dir = []() -> QString {
        if (KSandbox::isFlatpak()) {
            return qEnvironmentVariable("HOME") % u"/.local/share/applications/";
        }
        return QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    }();

    QDir(dir).mkpath(QStringLiteral("."));

    return dir;
}

bool WaydroidState::removeWaydroidApplications()
{
    const QDir appsDir(desktopFileDirectory());
    const auto fileInfos = appsDir.entryInfoList(QDir::Files);
    if (fileInfos.length() < 1) {
        return false;
    }

    bool allFileRemoved = true;

    for (const auto &fileInfo : fileInfos) {
        if (fileInfo.fileName().contains(QStringView(u".desktop"))) {
            const KDesktopFile desktopFile(fileInfo.filePath());
            const KConfigGroup configGroup = desktopFile.desktopGroup();

            if (!configGroup.hasKey(u"Categories"_s)) {
                continue;
            }

            const auto categories = configGroup.readEntry(u"Categories"_s);
            if (!categories.contains(u"X-WayDroid-App"_s)) {
                continue;
            }

            QFile file(fileInfo.filePath());
            if (!file.remove()) {
                allFileRemoved &= false;
                qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to remove: " << desktopFile.name();
            }
        }
    }

    return allFileRemoved;
}
