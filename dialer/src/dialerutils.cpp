/*
 * Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.

 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.

 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
**/

#include "dialerutils.h"

#include <QDebug>

#include <TelepathyQt/PendingOperation>
#include <TelepathyQt/PendingChannelRequest>
#include <TelepathyQt/PendingReady>
#include <TelepathyQt/Constants>
#include <TelepathyQt/PendingContacts>
#include <TelepathyQt/Types>
#include <TelepathyQt/ContactManager>

#include "phonenumbers/phonenumberutil.h"
#include "phonenumbers/asyoutypeformatter.h"

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
= default;

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

const QString DialerUtils::formatNumber(const QString& number)
{
    using namespace ::i18n::phonenumbers;

    // Get formatter instance
    QLocale locale;
    QStringList qcountry = locale.name().split('_');
    QString countrycode(qcountry.constLast());
    const char* country = countrycode.toUtf8().constData();
    PhoneNumberUtil* util = PhoneNumberUtil::GetInstance();
    AsYouTypeFormatter* formatter = util->PhoneNumberUtil::GetAsYouTypeFormatter(country);

    // Normalize input
    string stdnumber = number.toUtf8().constData();
    util->NormalizeDiallableCharsOnly(&stdnumber);

    // Format
    string formatted;
    formatter->Clear();
    for (char& c : stdnumber) {
        formatter->InputDigit(c, &formatted);
    }
    delete formatter;

    return QString::fromStdString(formatted);
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
