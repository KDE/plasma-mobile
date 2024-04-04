// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>
#include <qqmlregistration.h>

#include <KScreenDpms/Dpms>

/**
 * Utility class that provides useful functions related to dpms.
 *
 * @author Devin Lin <devin@kde.org>
 **/
class DPMSUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    DPMSUtil(QObject *parent = nullptr);

    Q_INVOKABLE void turnDpmsOn();
    Q_INVOKABLE void turnDpmsOff();

Q_SIGNALS:
    void dpmsTurnedOn(QScreen *screen);
    void dpmsTurnedOff(QScreen *screen);

private:
    QScopedPointer<KScreen::Dpms> m_dpms;
};
