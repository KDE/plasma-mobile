/*
    Copyright (C) 2009-2012  George Kiagiadakis <kiagiadakis.george@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "call-handler.h"
#include "call-manager.h"
#include "dialerutils.h"

#include <TelepathyQt/CallChannel>
#include <TelepathyQt/ChannelClassSpec>

static inline Tp::ChannelClassSpecList channelClassSpecList()
{
    return Tp::ChannelClassSpecList() << Tp::ChannelClassSpec::audioCall();
}

static inline Tp::AbstractClientHandler::Capabilities capabilities()
{
    Tp::AbstractClientHandler::Capabilities caps;

    //we support both audio and video in calls
    caps.setToken(TP_QT_IFACE_CHANNEL_TYPE_CALL + QLatin1String("/audio"));
//     caps.setToken(TP_QT_IFACE_CHANNEL_TYPE_CALL + QLatin1String("/video"));

    //transport methods - farstream supports them all
    caps.setToken(TP_QT_IFACE_CHANNEL_TYPE_CALL + QLatin1String("/ice"));
    caps.setToken(TP_QT_IFACE_CHANNEL_TYPE_CALL + QLatin1String("/gtalk-p2p"));
    caps.setToken(TP_QT_IFACE_CHANNEL_TYPE_CALL + QLatin1String("/shm"));

    //significant codecs
    caps.setToken(TP_QT_IFACE_CHANNEL_TYPE_CALL + QLatin1String("/video/h264"));

    return caps;
}

CallHandler::CallHandler(DialerUtils *utils)
    : Tp::AbstractClientHandler(channelClassSpecList(), capabilities())
{
    m_dialerUtils = utils;
    m_dialerUtils->setCallState("idle");
    qDebug() << "Call handler ready";
}

CallHandler::~CallHandler()
{
}

bool CallHandler::bypassApproval() const
{
    return true;
}

void CallHandler::handleChannels(const Tp::MethodInvocationContextPtr<> & context,
                                 const Tp::AccountPtr & account,
                                 const Tp::ConnectionPtr & connection,
                                 const QList<Tp::ChannelPtr> & channels,
                                 const QList<Tp::ChannelRequestPtr> & requestsSatisfied,
                                 const QDateTime & userActionTime,
                                 const Tp::AbstractClientHandler::HandlerInfo & handlerInfo)
{
    Q_UNUSED(account);
    Q_UNUSED(connection);
    Q_UNUSED(requestsSatisfied);
    Q_UNUSED(userActionTime);
    Q_UNUSED(handlerInfo);

    Q_FOREACH(const Tp::ChannelPtr & channel, channels) {
        Tp::CallChannelPtr callChannel = Tp::CallChannelPtr::qObjectCast(channel);
        if (!callChannel) {
            qDebug() << "Channel is not a Call channel. Ignoring";
            continue;
        }
        //check if any call manager is already handling this channel
        if (!handledCallChannels.contains(callChannel)) {
            handledCallChannels.append(callChannel);
            new CallManager(callChannel, m_dialerUtils, this);
        }
    }

    context->setFinished();
}
