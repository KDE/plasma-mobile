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
#include <TelepathyQt/PendingOperation>
#include <TelepathyQt/PendingChannelRequest>
#include <TelepathyQt/PendingReady>
#include <TelepathyQt/Constants>
#include <TelepathyQt/PendingContacts>
#include <TelepathyQt/Types>
#include <TelepathyQt/ContactManager>

DialerUtils::DialerUtils(const Tp::AccountPtr &simAccount, QObject *parent)
: QObject(parent),
  m_missedCalls(0),
  m_simAccount(simAccount),
  m_callDuration(0),
  m_callContactAlias(QString())
{
    Tp::PendingReady *op = m_simAccount->becomeReady(Tp::Features() << Tp::Account::FeatureCore);

    connect(op, &Tp::PendingOperation::finished, [=](){
        if (op->isError()) {
            qWarning() << "SIM card account failed to get ready:" << op->errorMessage();
        } else {
            qDebug() << "SIM Account ready to use";
        }
    });
}

DialerUtils::~DialerUtils()
{
}

void DialerUtils::dial(const QString &number)
{
    // FIXME: this should be replaced by kpeople thing
    auto pendingContact = m_simAccount->connection()->contactManager()->contactsForIdentifiers(QStringList() << number);

    connect(pendingContact, &Tp::PendingOperation::finished, [=](){
        if (pendingContact->contacts().size() < 1) {
            qWarning() << " no contacts";
            return;
        }
        qDebug() << "Starting call...";
        Tp::PendingChannelRequest *pendingChannel = m_simAccount->ensureAudioCall(pendingContact->contacts().first());
        connect(pendingChannel, &Tp::PendingChannelRequest::finished, [=](){
            if (pendingChannel->isError()) {
                qWarning() << "Error when requesting channel" << pendingChannel->errorMessage();
                setCallState("failed");
            }
        });
    });
}

QString DialerUtils::callState() const
{
    return m_callState;
}

void DialerUtils::setCallState(const QString &state)
{
    if (m_callState != state) {
        m_callState = state;
        Q_EMIT callStateChanged();
    }
}

uint DialerUtils::callDuration() const
{
    return m_callDuration;
}

void DialerUtils::setCallDuration(uint duration)
{
    m_callDuration = duration;
    Q_EMIT callDurationChanged();
}

QString DialerUtils::callContactAlias() const
{
    return m_callContactAlias;
}

void DialerUtils::setCallContactAlias(const QString &contactAlias)
{
    if (m_callContactAlias != contactAlias) {
        m_callContactAlias = contactAlias;
        Q_EMIT callContactAliasChanged();
    }
}

QString DialerUtils::callContactNumber() const
{
    return m_callContactNumber;
}

void DialerUtils::setCallContactNumber(const QString &contactNumber)
{
    if (m_callContactNumber != contactNumber) {
        m_callContactNumber = contactNumber;
        Q_EMIT callContactNumberChanged();
    }
}

bool DialerUtils::isIncomingCall() const
{
    return m_isIncomingCall;
}

void DialerUtils::setIsIncomingCall(bool isIncomingCall)
{
    if (m_isIncomingCall != isIncomingCall) {
        m_isIncomingCall = isIncomingCall;
        Q_EMIT isIncomingCallChanged();
    }
}

void DialerUtils::emitCallEnded()
{
    qDebug() << "Call ended:" << m_callContactNumber << m_callDuration;
    Q_EMIT callEnded(m_callContactNumber, m_callDuration, m_isIncomingCall);
    m_callDuration = 0;
    m_callContactNumber = QString();
    m_callContactAlias = QString();
}

void DialerUtils::resetMissedCalls()
{
    m_missedCalls = 0;
    if (m_callsNotification) {
        m_callsNotification->close();
    }
    m_callsNotification.clear();
}

#include "moc_dialerutils.cpp"
