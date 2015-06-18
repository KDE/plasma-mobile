/*
    Copyright (C) 2015  Martin Klapetek <mklapetek@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "tp-caller.h"

#include <TelepathyQt/Debug>
#include <TelepathyQt/Constants>
#include <TelepathyQt/ContactMessenger>
#include <TelepathyQt/PendingChannel>
#include <TelepathyQt/PendingReady>
#include <TelepathyQt/PendingContacts>
#include <TelepathyQt/TextChannel>
#include <TelepathyQt/Types>
#include <TelepathyQt/ContactManager>

TpCaller::TpCaller(QObject *parent)
    : QObject(parent)
{
    Tp::registerTypes();
    Tp::ConnectionFactoryPtr connectionFactory = Tp::ConnectionFactory::create(QDBusConnection::sessionBus(), Tp::Features() << Tp::Connection::FeatureConnected);

    Tp::ChannelFactoryPtr channelFactory = Tp::ChannelFactory::create(QDBusConnection::sessionBus());
    Tp::Features textFeatures = Tp::Features() << Tp::TextChannel::FeatureMessageQueue
                                               << Tp::TextChannel::FeatureMessageSentSignal
                                               << Tp::TextChannel::FeatureChatState
                                               << Tp::TextChannel::FeatureMessageCapabilities;

    channelFactory->addCommonFeatures(Tp::Channel::FeatureCore);
    channelFactory->addFeaturesForTextChats(textFeatures);

    m_simAccount = Tp::Account::create(TP_QT_ACCOUNT_MANAGER_BUS_NAME, QStringLiteral("/org/freedesktop/Telepathy/Account/ofono/ofono/account0"), connectionFactory, channelFactory);
    Tp::PendingReady *op = m_simAccount->becomeReady(Tp::Features() << Tp::Account::FeatureCore);

    connect(op, &Tp::PendingOperation::finished, [=](){
        if (op->isError()) {
            qWarning() << "SIM card account failed to get ready:" << op->errorMessage();
        } else {
            qDebug() << "SIM Account ready to use";
        }
    });
}

void TpCaller::dial(const QString &number)
{
    auto pendingContact = m_simAccount->connection()->contactManager()->contactsForIdentifiers(QStringList() << number);

    connect(pendingContact, &Tp::PendingOperation::finished, [=](){
        if (pendingContact->contacts().size() < 1) {
            qWarning() << " no contacts";
            return;
        }
        qDebug() << "Starting call...";
        Tp::PendingChannel *pendingChannel = m_simAccount->ensureAndHandleAudioCall(pendingContact->contacts().first());
        connect(pendingChannel, &Tp::PendingChannel::finished, [=](){
            if (pendingChannel->isError()) {
                qWarning() << "Error when requesting channel" << pendingChannel->errorMessage();
                return;
            }

            m_callChannel = Tp::CallChannelPtr(qobject_cast<Tp::CallChannel*>(pendingChannel->channel().data()));
            Q_EMIT callInProgressChanged();
        });
    });
}

bool TpCaller::callInProgress()
{
    return m_callChannel && m_callChannel->isValid() && m_callChannel->connection();
}

void TpCaller::hangUp()
{
    if (m_callChannel && m_callChannel->isValid() && m_callChannel->connection()) {
        qDebug() << "Hanging up";
        Tp::PendingOperation *op = m_callChannel->hangup();
        connect(op, &Tp::PendingOperation::finished, [=]() {
            if (op->isError()) {
                qWarning() << "Unable to hang up:" << op->errorMessage();
            }
            m_callChannel->requestClose();
        });
    }
}
