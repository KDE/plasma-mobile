/*
 * SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2024-2025 Florian RICHER <florian.richer@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "flashlightutil.h"

#include <cstring>
#include <fcntl.h>
#include <libudev.h>
#include <unistd.h>

#include <QDebug>
#include <QFileInfo>

#include <KAuth/Action>
#include <KAuth/ExecuteJob>

using namespace Qt::StringLiterals;

#define TORCH_SUBSYSTEM "leds"

FlashlightUtil::FlashlightUtil(QObject *parent)
    : QObject{parent}
    , m_device{nullptr}
    , m_isAvailable{false}
{
    findTorchDevice();
}

FlashlightUtil::~FlashlightUtil()
{
    if (m_device != nullptr) {
        udev_device_unref(m_device);
    }
}

void FlashlightUtil::toggleTorch()
{
    if (!isAvailable()) {
        qWarning() << "Flashlight not available";
        return;
    }

    const QString sysPath = udev_device_get_syspath(m_device);
    const QString brightness = m_torchEnabled ? "0" : m_maxBrightness;
    const QVariantMap args = {
        {u"sysPath"_s, sysPath},
        {u"brightness"_s, brightness},
    };

    KAuth::Action writeAction(u"org.kde.plasma.mobileshell.flashlighthelper.setbrightness"_s);
    writeAction.setHelperId(u"org.kde.plasma.mobileshell.flashlighthelper"_s);
    writeAction.setArguments(args);

    KAuth::ExecuteJob *job = writeAction.execute();
    if (!job->exec()) {
        qDebug() << "Flashlight can't be toggled: kauth returned an error code:" << job->error() << " message: " << job->errorString();
        return;
    }

    m_torchEnabled = !m_torchEnabled;
    Q_EMIT torchChanged(m_torchEnabled);
}

bool FlashlightUtil::torchEnabled() const
{
    return m_torchEnabled;
}

bool FlashlightUtil::isAvailable() const
{
    return m_isAvailable;
}

void FlashlightUtil::findTorchDevice()
{
    if (m_device != nullptr) {
        udev_device_unref(m_device);
    }
    m_device = nullptr;
    m_isAvailable = false;

    struct udev *udev = udev_new();
    struct udev_enumerate *enumerate = udev_enumerate_new(udev);

    udev_enumerate_add_match_subsystem(enumerate, TORCH_SUBSYSTEM);
    udev_enumerate_add_match_sysname(enumerate, "*:torch");
    udev_enumerate_add_match_sysname(enumerate, "*:flash");
    udev_enumerate_scan_devices(enumerate);

    struct udev_list_entry *devices = udev_enumerate_get_list_entry(enumerate);
    struct udev_list_entry *entry = nullptr;

    struct udev_device *device = nullptr;

    udev_list_entry_foreach(entry, devices)
    {
        const char *path = udev_list_entry_get_name(entry);

        if (path == nullptr) {
            continue;
        }

        if (device != nullptr) {
            udev_device_unref(device); // Use to free memory from previous loop iteration
        }

        device = udev_device_new_from_syspath(udev, path);

        if (device == nullptr) {
            continue;
        }

        qInfo() << "Found flashlight device : " << path;

        const char *color = udev_device_get_sysattr_value(device, "color");

        if (color == nullptr) {
            continue;
        }

        qInfo() << "Flash color : " << color;

        if (std::strcmp(color, "white") == 0) {
            break;
        }
    }

    if (device == nullptr) {
        qWarning() << "No flashlight device found";
        return;
    }

    const char *maxBrightness = udev_device_get_sysattr_value(device, "max_brightness");

    if (maxBrightness == nullptr) {
        qWarning() << "Failed to read max_brightness from udev device";
        return;
    }

    qInfo() << "Flash maxBrightness : " << maxBrightness;

    const char *brightness = udev_device_get_sysattr_value(device, "brightness");

    if (brightness == nullptr) {
        qWarning() << "Failed to read brightness from udev device";
        return;
    }

    qInfo() << "Flash brightness : " << brightness;

    m_maxBrightness = maxBrightness;
    m_device = device;
    m_isAvailable = true;
    m_torchEnabled = std::strcmp(brightness, "0") != 0;

    udev_enumerate_unref(enumerate);
    udev_unref(udev);
}
