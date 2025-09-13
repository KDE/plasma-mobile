// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "volumeosdlistener.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusServiceWatcher>
#include <QDebug>
#include <QString>

using namespace Qt::StringLiterals;

VolumeOSDListener::VolumeOSDListener(QObject *parent)
    : QObject{parent}
{
    QDBusServiceWatcher *watcher =
        new QDBusServiceWatcher(QStringLiteral("org.kde.plasmashell"), QDBusConnection::sessionBus(), QDBusServiceWatcher::WatchForOwnerChange, this);

    connect(watcher, &QDBusServiceWatcher::serviceRegistered, this, [this]() -> void {
        connectDBus();
    });

    connectDBus();
}

void VolumeOSDListener::connectDBus()
{
    bool success = QDBusConnection::sessionBus().connect(QStringLiteral("org.kde.plasmashell"),
                                                         QStringLiteral("/org/kde/osdService"),
                                                         QStringLiteral("org.kde.osdService"),
                                                         QStringLiteral("osdProgress"),
                                                         this,
                                                         SLOT(onOSDProgress(QString, int, int, QString)));
}

void VolumeOSDListener::onOSDProgress(const QString &icon, int volume, int maxVolume, const QString &text)
{
    Q_UNUSED(text)

    if (icon == "audio-volume-muted"_L1 || icon == "audio-volume-low"_L1 || icon == "audio-volume-medium"_L1 || icon == "audio-volume-high"_L1) {
        Q_EMIT showOSD(icon, volume, maxVolume);
    }
}
