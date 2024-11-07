/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2018 Bhushan Shah <bshah@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "shellutil.h"

#include <KConfigGroup>
#include <KFileUtils>
#include <KLocalizedString>
#include <KNotification>
#include <KNotificationJobUiDelegate>

#include <QQuickWindow>

#include <QDBusPendingReply>
#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QProcess>

#include <QTextDocumentFragment>
#include <QtWaylandClient/private/qwaylandwindow_p.h>


#define FORMAT24H "HH:mm:ss"


ShellUtil::ShellUtil(QObject *parent) : QObject{parent}, m_localeConfig {
    KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig) } {
}

void ShellUtil::stackItemBefore(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackBefore(item2);
}

void ShellUtil::stackItemAfter(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackAfter(item2);
}

void ShellUtil::executeCommand(const QString &command)
{
    qWarning() << "Executing" << command;
    const QStringList commandAndArguments = QProcess::splitCommand(command);
    QProcess::startDetached(commandAndArguments.front(), commandAndArguments.mid(1));
}

bool ShellUtil::isSystem24HourFormat()
{
    // only load the config watcher if this function is actually used once
    if (!m_localeConfigWatcher) {
        m_localeConfigWatcher = KConfigWatcher::create(m_localeConfig);

        // watch for changes to locale config, to update 12/24 hour time
        connect(m_localeConfigWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group) -> void {
            if (group.name() == "Locale") {
                // we have to reparse for new changes (from system settings)
                m_localeConfig->reparseConfiguration();
                Q_EMIT isSystem24HourFormatChanged();
            }
        });
    }

    KConfigGroup localeSettings = KConfigGroup(m_localeConfig, "Locale");

    QString timeFormat = localeSettings.readEntry("TimeFormat", QStringLiteral(FORMAT24H));
    return timeFormat == QStringLiteral(FORMAT24H);
}

void ShellUtil::launchApp(const QString &storageId)
{
    KService::Ptr service = KService::serviceByStorageId(storageId);
    if (!service) {
        qWarning() << "Could not find" << storageId;
        return;
    }

    auto job = new KIO::ApplicationLauncherJob(service, this);
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoHandlingEnabled));
    job->start();
}

void ShellUtil::setInputTransparent(QQuickWindow *window, bool transparent) {
    if (window) {
        Qt::WindowFlags flags = window->flags();
        if (transparent) {
            flags |= Qt::WindowTransparentForInput;
        } else {
            flags &= ~Qt::WindowTransparentForInput;
        }
        window->setFlags(flags);
    }
}

void ShellUtil::setInputRegion(QWindow *window, const QRect &region) {
    auto waylandWindow = dynamic_cast<QtWaylandClient::QWaylandWindow *>(window->handle());
    if (!waylandWindow) {
        qWarning() << "Failed to retrieve Wayland window handle.";
        return;
    }
    
    auto waylandDisplay = dynamic_cast<QtWaylandClient::QWaylandDisplay *>(waylandWindow->display());
    if (!waylandDisplay) {
        qWarning() << "Failed to retrieve Wayland display.";
        return;
    }

    wl_compositor *compositorResource = static_cast<wl_compositor *>(waylandDisplay->compositor()->object());
    if (!compositorResource) {
        qWarning() << "Failed to retrieve compositor.";
        return;
    }

    wl_surface *surface = waylandWindow->wlSurface();
    if (!surface) {
        qWarning() << "Failed to retrieve Wayland surface.";
        return;
    }

    if (region.isEmpty()) {
        wl_surface_set_input_region(surface, nullptr);
    } else {
        wl_region *inputRegion = wl_compositor_create_region(compositorResource);

        wl_region_add(inputRegion, region.x(), region.y(), region.width(), region.height());
        wl_surface_set_input_region(surface, inputRegion);
        wl_region_destroy(inputRegion);
    }

    wl_surface_commit(surface);
}

QString ShellUtil::toPlainText(QString htmlString) {
    return QTextDocumentFragment::fromHtml(htmlString).toPlainText();
}
