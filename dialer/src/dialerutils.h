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

#ifndef DIALERUTILS_H
#define DIALERUTILS_H

#include <QObject>
#include <QPointer>
#include <KNotification>

#include <TelepathyQt/Account>

class DialerUtils : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString callState READ callState NOTIFY callStateChanged);
    Q_PROPERTY(uint callDuration READ callDuration NOTIFY callDurationChanged);
    Q_PROPERTY(QString callContactAlias READ callContactAlias NOTIFY callContactAliasChanged);
    Q_PROPERTY(QString callContactNumber READ callContactNumber NOTIFY callContactNumberChanged);

public:

    DialerUtils(const Tp::AccountPtr &simAccount, QObject *parent = 0);
    virtual ~DialerUtils();

    QString callState() const;
    void setCallState(const QString &state);

    uint callDuration() const;
    void setCallDuration(uint duration);

    QString callContactAlias() const;
    void setCallContactAlias(const QString &contactAlias);

    QString callContactNumber() const;
    void setCallContactNumber(const QString &contactNumber);

    Q_INVOKABLE void resetMissedCalls();
    Q_INVOKABLE void dial(const QString &number);

Q_SIGNALS:
    void missedCallsActionTriggered();
    void callStateChanged();
    void callDurationChanged();
    void callContactAliasChanged();
    void callContactNumberChanged();
    void acceptCall();
    void rejectCall();
    void hangUp();

private:
    QPointer <KNotification> m_callsNotification;
    QPointer <KNotification> m_ringingNotification;
    int m_missedCalls;
    QString m_callState;
    Tp::AccountPtr m_simAccount;
    QString m_callContactAlias;
    QString m_callContactNumber;
    uint m_callDuration;
};


#endif
