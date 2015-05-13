/*
 * Copyright 2015 Marco Martin <mart@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#include "dialerutils.h"

#include <QDebug>

#include <KLocalizedString>

DialerUtils::DialerUtils(QObject *parent)
: QObject(parent),
  m_missedCalls(0)
{
}

DialerUtils::~DialerUtils()
{
}

void DialerUtils::notifyMissedCall(const QString &caller, const QString &description)
{
    qWarning() << "Missed Call.";

    ++m_missedCalls;
    if (!m_callsNotification) {
        m_callsNotification = new KNotification("callMissed", KNotification::Persistent, 0);
    }
    m_callsNotification->setComponentName("plasma_dialer");
    m_callsNotification->setIconName("call-start");
    if (m_missedCalls == 1) {
        m_callsNotification->setTitle(i18n("Missed call from %1", caller));
        m_callsNotification->setText(description);
    } else {
        m_callsNotification->setTitle(i18n("%1 calls missed", m_missedCalls));
        m_callsNotification->setText(i18n("Last call: %1", description));
    }

    QStringList actions;
    actions.append(i18n("View"));
    m_callsNotification->setActions(actions);
    QObject::connect(m_callsNotification.data(), &KNotification::action1Activated,
        [=]() {
            qWarning()<<"View action activated";
            emit missedCallsActionTriggered();
            resetMissedCalls();
        });

    if (m_missedCalls == 1) {
        m_callsNotification->sendEvent();
    } else {
        m_callsNotification->update();
    }
}

void DialerUtils::resetMissedCalls()
{
    m_missedCalls = 0;
    if (m_callsNotification) {
        m_callsNotification->close();
    }
    m_callsNotification.clear();
}

void DialerUtils::notifyRinging()
{
    if (!m_ringingNotification) {
        m_ringingNotification = new KNotification("ringing", KNotification::Persistent, 0);
        m_ringingNotification->setComponentName("plasma_dialer");
    }
    m_ringingNotification->sendEvent();
}

void DialerUtils::stopRinging()
{
    if (m_ringingNotification) {
        m_ringingNotification->close();
    }
}

#include "moc_dialerutils.cpp"
