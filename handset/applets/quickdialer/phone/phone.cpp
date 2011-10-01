/*
 *   Copyright 2010 Alexis Menard <menard@kde.org>
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <KDebug>

#include "phone.h"

Phone::Phone(QObject *parent)
    : QObject(parent)
{
    QDBusConnection connSystemBus = QDBusConnection::systemBus();
    m_dbusPhone = new QDBusInterface("com.nokia.csd.Call", "/com/nokia/csd/call",
                                     "com.nokia.csd.Call", connSystemBus, this);

    m_dbusPhoneInstance = new QDBusInterface("com.nokia.csd.Call", "/com/nokia/csd/call/1",
                                     "com.nokia.csd.Call.Instance", connSystemBus, this);

    connect(m_dbusPhoneInstance, SIGNAL(CallStatus(int)),
            this, SLOT(callStatus(int)));
}

Phone::~Phone()
{
    delete m_dbusPhone;
}

void Phone::call(const QString &number) {
    kDebug()<<"CALLING NUMBER"<<number;
    QList<QVariant> args;
    args << number;
    args << 0;
    m_dbusPhone->callWithCallback("CreateWith", args, this,
                                  SLOT(callReturned()),
                                  SLOT(callError(QDBusError&)));
}

void Phone::hangup()
{
    QList<QVariant> args;
    m_dbusPhone->callWithCallback("Release", args, this,
                                  SLOT(callReturned()));
}

void Phone::callReturned()
{
}

void Phone::callError(QDBusError &error)
{
}

void Phone::callStatus(int value)
{
    // >= 2 (=CSD_CALL_STATUS_COMING)
    if (value >= 2) {
        qWarning() << "----> RECEIVING CALL!!!";
        // answer code?
    }
}

#include "phone.moc"
