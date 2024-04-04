//  SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "dpmsutil.h"

#include <QGuiApplication>

DPMSUtil::DPMSUtil(QObject *parent)
    : QObject{parent}
    , m_dpms(new KScreen::Dpms)
{
    connect(m_dpms.get(), &KScreen::Dpms::modeChanged, this, [this](auto mode, auto screen) {
        switch (mode) {
        case KScreen::Dpms::On:
            Q_EMIT dpmsTurnedOn(screen);
            break;
        case KScreen::Dpms::Off:
        case KScreen::Dpms::Standby:
        case KScreen::Dpms::Suspend:
        default:
            Q_EMIT dpmsTurnedOff(screen);
            break;
        }
    });
}

void DPMSUtil::turnDpmsOn()
{
    m_dpms->switchMode(KScreen::Dpms::On);
}

void DPMSUtil::turnDpmsOff()
{
    m_dpms->switchMode(KScreen::Dpms::Off);
}
