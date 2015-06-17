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

#ifndef TPCALLER_H
#define TPCALLER_H

#include <QObject>
#include <TelepathyQt/Account>
#include <TelepathyQt/Channel>

class TpCaller : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool callInProgress READ callInProgress NOTIFY callInProgressChanged);

public:
    TpCaller(QObject *parent = 0);
    Q_INVOKABLE void dial(const QString &number);
    Q_INVOKABLE void hangUp();

    bool callInProgress();

Q_SIGNALS:
    void callInProgressChanged();

private:
    Tp::AccountPtr m_simAccount;
    Tp::ChannelPtr m_callChannel;
};

#endif // TPCALLER_H

