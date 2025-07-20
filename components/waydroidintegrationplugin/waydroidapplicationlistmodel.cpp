/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "waydroidapplicationlistmodel.h"
#include "waydroidintegrationplugin_debug.h"
#include "waydroidshared.h"

#include <QLoggingCategory>
#include <QProcess>
#include <QStringLiteral>

#include <KLocalizedString>

using namespace Qt::StringLiterals;
using namespace std::chrono_literals;

WaydroidApplicationListModel::WaydroidApplicationListModel(WaydroidState *parent)
    : QAbstractListModel{parent}
    , m_waydroidState{parent}
    , m_refreshTimer{new QTimer{this}}
{
    // Waydroid does not return all installed applications immediately, so we need to refresh regularly.
    m_refreshTimer->setInterval(1s);
    m_refreshTimer->setSingleShot(false);
    m_refreshTimer->start();

    connect(m_refreshTimer, &QTimer::timeout, this, &WaydroidApplicationListModel::refreshApplications);
    connect(parent, &WaydroidState::sessionStatusChanged, this, &WaydroidApplicationListModel::refreshApplications);
}

WaydroidApplicationListModel::~WaydroidApplicationListModel() = default;

void WaydroidApplicationListModel::loadApplications(const QList<WaydroidApplication::Ptr> applications)
{
    if (m_waydroidState->sessionStatus() != WaydroidState::SessionRunning) {
        return;
    }

    qCDebug(WAYDROIDINTEGRATIONPLUGIN) << "Reload waydroid apps";

    QMap<QString, int> appIdMap; // <packageName, index>
    for (int i = 0; i < m_applications.size(); ++i) {
        const auto &application = m_applications[i];
        appIdMap.insert(application->packageName(), i);
    }

    QList<WaydroidApplication::Ptr> toInsert;

    for (const WaydroidApplication::Ptr &application : applications) {
        auto it = appIdMap.find(application->packageName());
        if (it != appIdMap.end()) {
            // Application already in m_applications
            appIdMap.erase(it);
        } else {
            // Application needs to be inserted into m_applications
            toInsert.append(std::move(application));
        }
    }

    QList<int> toRemove;
    for (int index : appIdMap.values()) {
        toRemove.append(index);
    }

    std::sort(toRemove.begin(), toRemove.end());

    // Remove indices first, from end to start to avoid indicies changing
    for (int i = toRemove.size() - 1; i >= 0; --i) {
        int ind = toRemove[i];

        beginRemoveRows({}, ind, ind);
        m_applications.removeAt(ind);
        endRemoveRows();
    }

    // Append new elements
    for (const WaydroidApplication::Ptr &application : toInsert) {
        beginInsertRows({}, m_applications.size(), m_applications.size());
        m_applications.append(application);
        endInsertRows();
    }
}

void WaydroidApplicationListModel::refreshApplications()
{
    QList<WaydroidApplication::Ptr> applications;

    QStringList arguments = {u"app"_s, u"list"_s};

    QProcess *process = new QProcess(m_waydroidState);
    process->start(WAYDROID_COMMAND, arguments);

    connect(process, &QProcess::finished, this, [this, process](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitCode != 0 || exitStatus == QProcess::ExitStatus::CrashExit) {
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to run waydroid app list command: " << process->readAllStandardError();
            return;
        }

        const QByteArray data = process->readAllStandardOutput();
        if (data.isEmpty()) {
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Empty data: " << process->readAllStandardError();
            return;
        }

        qCDebug(WAYDROIDINTEGRATIONPLUGIN) << "Waydroid output: " << data;
        QTextStream output = QTextStream(data);

        QList<WaydroidApplication::Ptr> applications;
        while (!output.atEnd()) {
            const WaydroidApplication::Ptr app = WaydroidApplication::fromWaydroidLog(output);
            if (app == nullptr) {
                qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Failed to fetch the application: Maybe wrong QTextStream cursor position.";
                break;
            }

            qCDebug(WAYDROIDINTEGRATIONPLUGIN) << "Waydroid application found: " << app.get()->name() << " (" << app.get()->packageName() << ")";
            applications.append(app);
        }

        loadApplications(applications);
    });
}

QHash<int, QByteArray> WaydroidApplicationListModel::roleNames() const
{
    return {{DelegateRole, QByteArrayLiteral("delegate")}, {NameRole, QByteArrayLiteral("name")}, {IdRole, QByteArrayLiteral("id")}};
}

QVariant WaydroidApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_applications.count()) {
        return QVariant();
    }

    WaydroidApplication::Ptr app = m_applications.at(index.row());

    switch (role) {
    case Qt::DisplayRole:
    case DelegateRole:
        return QVariant::fromValue(app.get());
    case NameRole:
        return app->name();
    case IdRole:
        return app->packageName();
    default:
        return QVariant();
    }
}

int WaydroidApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applications.count();
}

void WaydroidApplicationListModel::installApk(const QString apkFile)
{
    const QStringList arguments{u"app"_s, u"install"_s, apkFile};

    QProcess *process = new QProcess(this);
    process->start(WAYDROID_COMMAND, arguments);

    connect(process, &QProcess::finished, this, [this, apkFile, process](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
            Q_EMIT actionFinished(i18n("Application has been installed"));
        } else {
            Q_EMIT errorOccurred(i18n("Installation Failed"));
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Error occured during installation of " << apkFile << ": " << process->readAllStandardError();
        }
    });
}

void WaydroidApplicationListModel::deleteApplication(const QString appId)
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
            Q_EMIT errorOccurred(i18n("Application uninstall failed"));
            qCWarning(WAYDROIDINTEGRATIONPLUGIN) << "Error occured during uninstallation of " << appId << ": " << errorLog;
        }
    });
}