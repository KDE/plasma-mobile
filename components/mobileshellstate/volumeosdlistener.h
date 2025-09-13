// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>

class VolumeOSDListener : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    VolumeOSDListener(QObject *parent = nullptr);

Q_SIGNALS:
    void showOSD(const QString &icon, int volume, int maxVolume);

private Q_SLOTS:
    void onOSDProgress(const QString &icon, int volume, int maxVolume, const QString &text);

private:
    void connectDBus();
};
