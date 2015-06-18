/*
    Copyright (C) 2012 George Kiagiadakis <kiagiadakis.george@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef CALL_MANAGER_H
#define CALL_MANAGER_H

#include <QObject>
#include <TelepathyQt/CallChannel>

class DialerUtils;

class CallManager : public QObject
{
    Q_OBJECT
public:
    explicit CallManager(const Tp::CallChannelPtr &callChannel, DialerUtils *dialerUtils, QObject *parent = 0);
    virtual ~CallManager();

private Q_SLOTS:
    void onCallStateChanged(Tp::CallState state);
    void onCallAccepted();
    void onCallRejected();
    void onHangUpRequested();

private:
    void ensureCallWindow();

private:
    struct Private;
    Private *const d;
};

#endif // CALL_MANAGER_H
