/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QVariantMap>
#include <qqmlintegration.h>

#include "screenshot2interface.h"

class ScreenShotUtil : public QObject
{
    Q_OBJECT
    QML_SINGLETON

public:
    ScreenShotUtil(QObject *parent = nullptr);

    Q_INVOKABLE void takeScreenShot();
    void handleMetaDataReceived(const QVariantMap &metadata, int fd);

private:
    OrgKdeKWinScreenShot2Interface *m_screenshotInterface;
};
