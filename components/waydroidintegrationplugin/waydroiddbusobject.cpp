/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "waydroiddbusobject.h"
#include "waydroidadaptor.h"
#include "waydroidapplicationdbusobject.h"
#include "waydroidintegrationplugin_debug.h"
#include "waydroidshared.h"

#include <QDBusConnection>
#include <QDir>
#include <QLoggingCategory>
#include <QProcess>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QTimer>

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

WaydroidDBusObject::WaydroidDBusObject(QObject *parent)
    : QObject{parent}
{
}

void WaydroidDBusObject::registerObject()
{
    if (!m_dbusInitialized) {
        new WaydroidAdaptor{this};
        QDBusConnection::sessionBus().registerObject(u"/Waydroid"_s, this);
        m_dbusInitialized = true;

        // Connect it-self to auto-refresh when required status has changed
        connect(this, &WaydroidDBusObject::statusChanged, this, &WaydroidDBusObject::refreshSessionInfo);
        connect(this, &WaydroidDBusObject::statusChanged, this, &WaydroidDBusObject::refreshInstallationInfo);
        connect(this, &WaydroidDBusObject::sessionStatusChanged, this, &WaydroidDBusObject::refreshPropsInfo);
        connect(this, &WaydroidDBusObject::sessionStatusChanged, this, &WaydroidDBusObject::refreshApplications);

        refreshSupportsInfo();
    }
}

void WaydroidDBusObject::initialize(const int systemType, const int romType, const bool forced)
{
    if (m_status == Initializing) {
        return;
    }

    m_status = Initializing;
    Q_EMIT statusChanged();

    QString systemTypeArg;
    switch (systemType) {
    case Vanilla:
        systemTypeArg = "VANILLA";
        break;
    case Foss:
        systemTypeArg = "FOSS";
        break;
    case Gapps:
        systemTypeArg = "GAPPS";
        break;
    default:
        systemTypeArg = "VANILLA";
        break;
    }

    QString romTypeArg;
    switch (romType) {
    case Lineage:
        romTypeArg = "lineage";
        break;
    case Bliss:
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

    connect(job, &KAuth::ExecuteJob::finished, this, [this](KJob *job, auto) {
        if (job->error() == 0) {
            m_status = Initialized;
        } else {
            Q_EMIT errorOccurred(i18n("Failed to initialize Waydroid."), job->errorString());

            m_status = NotInitialized;
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "KAuth returned an error code:" << job->error() << " message: " << job->errorString();
        }

        Q_EMIT statusChanged();
    });
}

void WaydroidDBusObject::startSession()
{
    if (m_sessionStatus == SessionStarting || m_sessionStatus == SessionRunning) {
        return;
    }

    m_sessionStatus = SessionStarting;
    Q_EMIT sessionStatusChanged();

    const QStringList arguments{u"session"_s, u"start"_s};

    auto *process = new QProcess(this);
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

        Q_EMIT errorOccurred(i18n("Failed to start the Waydroid session."), errorString);

        qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to start the Waydroid session: " << errorString;
    });

    checkSessionStarting(10);
}

void WaydroidDBusObject::stopSession()
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

void WaydroidDBusObject::resetWaydroid()
{
    if (m_status != Initialized || m_sessionStatus == SessionStarting) {
        return;
    }

    m_status = Resetting;
    Q_EMIT statusChanged();

    if (m_sessionStatus == SessionRunning) {
        stopSession();
    }

    const QVariantMap args = {{u"homeDir"_s, QDir::homePath()}};

    KAuth::Action writeAction(u"org.kde.plasma.mobileshell.waydroidhelper.reset"_s);
    writeAction.setHelperId(u"org.kde.plasma.mobileshell.waydroidhelper"_s);
    writeAction.setArguments(args);

    KAuth::ExecuteJob *job = writeAction.execute();
    job->start();

    connect(job, &KAuth::ExecuteJob::finished, this, [this](KJob *job, auto) {
        removeWaydroidApplications();

        if (job->error() == 0) {
            m_status = NotInitialized;
        } else {
            Q_EMIT errorOccurred(i18n("Failed to reset Waydroid."), "");

            m_status = Initialized;
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "KAuth returned an error code:" << job->error() << " message: " << job->errorString();
        }

        Q_EMIT statusChanged();
    });
}

void WaydroidDBusObject::installApk(const QString apkFile)
{
    const QStringList arguments{u"app"_s, u"install"_s, apkFile};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);

    connect(process, &QProcess::finished, this, [this, apkFile, process](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
            Q_EMIT actionFinished(i18n("Application has been installed"));
        } else {
            Q_EMIT actionFailed(i18n("Installation Failed"));
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Error occurred during installation of " << apkFile << ": " << process->readAllStandardError();
        }
    });
}

void WaydroidDBusObject::deleteApplication(const QString appId)
{
    const QStringList arguments{u"app"_s, u"remove"_s, appId};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);

    connect(process, &QProcess::finished, this, [this, appId, process](int exitCode, QProcess::ExitStatus exitStatus) {
        Q_UNUSED(exitCode);
        Q_UNUSED(exitStatus);

        const QByteArray errorLog = process->readAllStandardError();

        // "waydroid app remove" send log on stderr but keep exitCode to 0
        if (errorLog.isEmpty()) {
            Q_EMIT actionFinished(i18n("Application has been deleted"));
        } else {
            Q_EMIT actionFailed(i18n("Application uninstall failed"));
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Error occurred during uninstallation of " << appId << ": " << errorLog;
        }
    });
}

int WaydroidDBusObject::status() const
{
    return m_status;
}

int WaydroidDBusObject::sessionStatus() const
{
    return m_sessionStatus;
}

int WaydroidDBusObject::systemType() const
{
    return m_systemType;
}

QString WaydroidDBusObject::ipAddress() const
{
    return m_ipAddress;
}

QString WaydroidDBusObject::androidId() const
{
    return m_androidId;
}

bool WaydroidDBusObject::multiWindows() const
{
    return m_multiWindows;
}

void WaydroidDBusObject::setMultiWindows(const bool multiWindows)
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

bool WaydroidDBusObject::suspend() const
{
    return m_suspend;
}

void WaydroidDBusObject::setSuspend(const bool suspend)
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

bool WaydroidDBusObject::uevent() const
{
    return m_uevent;
}

void WaydroidDBusObject::setUevent(const bool uevent)
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

QList<QDBusObjectPath> WaydroidDBusObject::applications() const
{
    QList<QDBusObjectPath> paths;
    for (const auto &app : m_applicationObjects) {
        paths.push_back(app->objectPath());
    }
    return paths;
}

void WaydroidDBusObject::refreshSupportsInfo()
{
    const QStringList arguments{u"-h"_s};

    auto process = QProcess(this);
    process.start(WAYDROID_COMMAND, arguments);
    process.waitForFinished();

    const int exitCode = process.exitCode();
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

void WaydroidDBusObject::refreshInstallationInfo()
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

void WaydroidDBusObject::refreshSessionInfo()
{
    if (m_status != Initialized) {
        return;
    }

    const QString output = fetchSessionInfo();

    const QString sessionMatchResult = extractRegExp(output, sessionRegExp);
    SessionStatus newSessionStatus;

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

QString WaydroidDBusObject::fetchSessionInfo()
{
    const QStringList arguments{u"status"_s};

    auto process = QProcess(this);
    process.start(WAYDROID_COMMAND, arguments);
    process.waitForFinished();

    return process.readAllStandardOutput();
}

void WaydroidDBusObject::refreshAndroidId()
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

            if (m_androidId.isEmpty()) {
                Q_EMIT actionFailed(i18n("Android ID not found"));
            }
        } else {
            m_androidId = "";
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "KAuth returned an error code:" << executeJob->error();
        }

        Q_EMIT androidIdChanged();
    });
}

void WaydroidDBusObject::refreshPropsInfo()
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

QString WaydroidDBusObject::fetchPropValue(const QString key, const QString defaultValue)
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

bool WaydroidDBusObject::writePropValue(const QString key, const QString value)
{
    const QStringList arguments{u"prop"_s, u"set"_s, key, value};

    auto process = QProcess(this);
    process.start(WAYDROID_COMMAND, arguments);
    process.waitForFinished();

    return process.exitCode() == 0;
}

QString WaydroidDBusObject::extractRegExp(const QString text, const QRegularExpression regExp) const
{
    const QRegularExpressionMatch match = regExp.match(text);

    if (match.hasMatch() && match.lastCapturedIndex() > 0) {
        return match.captured(match.lastCapturedIndex());
    } else {
        return "";
    }
}

void WaydroidDBusObject::checkSessionStarting(const int limit, const int tried)
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

QString WaydroidDBusObject::desktopFileDirectory()
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

bool WaydroidDBusObject::removeWaydroidApplications()
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

void WaydroidDBusObject::refreshApplications()
{
    if (m_sessionStatus != SessionRunning) {
        // Clear existing applications when session is not running
        for (const auto &appObject : m_applicationObjects) {
            appObject->unregisterObject();
        }
        m_applicationObjects.clear();
        return;
    }

    const QString output = fetchApplicationsList();
    if (output.isEmpty()) {
        return;
    }

    QTextStream inFile(const_cast<QString *>(&output), QIODevice::ReadOnly);
    const auto newApplications = WaydroidApplicationDBusObject::parseApplicationsFromWaydroidLog(inFile);

    // Create a map of existing applications by package name for efficient lookup
    QMap<QString, int> existingAppMap;
    for (int i = 0; i < m_applicationObjects.size(); ++i) {
        const auto &application = m_applicationObjects[i];
        existingAppMap.insert(application->packageName(), i);
    }

    QList<WaydroidApplicationDBusObject::Ptr> toInsert;

    // Check which applications need to be added or are already present
    for (const auto &application : newApplications) {
        if (!application->name().isEmpty() && !application->packageName().isEmpty()) {
            auto it = existingAppMap.find(application->packageName());
            if (it != existingAppMap.end()) {
                // Application already exists, remove from map to mark as kept
                existingAppMap.erase(it);
            } else {
                // Application needs to be inserted
                toInsert.append(application);
            }
        }
    }

    // Remove applications that are no longer present
    QList<int> toRemove;
    for (const int index : existingAppMap.values()) {
        toRemove.append(index);
    }

    std::sort(toRemove.begin(), toRemove.end());

    // Remove indices from end to start to avoid index shifting
    for (int i = toRemove.size() - 1; i >= 0; --i) {
        int ind = toRemove[i];
        const auto application = m_applicationObjects[ind];
        m_applicationObjects.removeAt(ind);
        Q_EMIT applicationRemoved(application->objectPath());
        application->unregisterObject();
    }

    // Add new applications and register them
    for (const auto &application : toInsert) {
        application->registerObject();
        m_applicationObjects.append(application);
        Q_EMIT applicationAdded(application->objectPath());
    }
}

QString WaydroidDBusObject::fetchApplicationsList()
{
    const QStringList arguments{u"app"_s, u"list"_s};

    auto process = QProcess(this);
    process.start(WAYDROID_COMMAND, arguments);
    process.waitForFinished();

    if (process.exitCode() != 0) {
        qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to fetch applications list: " << process.readAllStandardError();
        return QString{};
    }

    return process.readAllStandardOutput();
}
