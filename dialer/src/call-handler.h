/*
    Copyright (C) 2009  George Kiagiadakis <kiagiadakis.george@gmail.com>

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
#ifndef CALL_HANDLER_H
#define CALL_HANDLER_H

#include <TelepathyQt/AbstractClientHandler>

class DialerUtils;

class CallHandler : public QObject, public Tp::AbstractClientHandler
{
    Q_OBJECT
public:
    CallHandler(DialerUtils *utils);
    virtual ~CallHandler();

    virtual bool bypassApproval() const;
    virtual void handleChannels(const Tp::MethodInvocationContextPtr<> & context,
                                const Tp::AccountPtr & account,
                                const Tp::ConnectionPtr & connection,
                                const QList<Tp::ChannelPtr> & channels,
                                const QList<Tp::ChannelRequestPtr> & requestsSatisfied,
                                const QDateTime & userActionTime,
                                const Tp::AbstractClientHandler::HandlerInfo & handlerInfo);
private:
    QList<Tp::CallChannelPtr> handledCallChannels;
    DialerUtils *m_dialerUtils;
};

#endif
