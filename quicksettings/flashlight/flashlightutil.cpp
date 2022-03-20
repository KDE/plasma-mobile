/*
 * SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "flashlightutil.h"

#include <fcntl.h>
#include <unistd.h>

#include <QDebug>

FlashlightUtil::FlashlightUtil(QObject *parent)
    : QObject{parent}
    , m_torchEnabled{false}
{
}

void FlashlightUtil::toggleTorch()
{
    // FIXME this is hardcoded to the PinePhone for now
    static auto FLASH_SYSFS_PATH = "/sys/devices/platform/led-controller/leds/white:flash/brightness";
    int fd = open(FLASH_SYSFS_PATH, O_WRONLY);

    if (fd < 0) {
        qWarning() << "Unable to open file %s" << FLASH_SYSFS_PATH;
        return;
    }

    write(fd, m_torchEnabled ? "0" : "1", 1);
    close(fd);
    m_torchEnabled = !m_torchEnabled;
    Q_EMIT torchChanged(m_torchEnabled);
}

bool FlashlightUtil::torchEnabled() const
{
    return m_torchEnabled;
}
