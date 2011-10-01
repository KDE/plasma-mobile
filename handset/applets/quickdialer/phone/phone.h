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

#ifndef PLASMA_PHONE
#define PLASMA_PHONE

#include <QObject>
#include <QtDBus>
#include <QDBusError>

class Phone : public QObject
{
    Q_OBJECT

public:
    Phone(QObject *parent = 0);
    ~Phone();

public slots:
    void call(const QString &number);
    void hangup();

signals:
    void calling();
    void receiving();

protected slots:
    void callReturned();
    void callError(QDBusError &error);
    void callStatus(int value);

private:
    QDBusInterface *m_dbusPhone;
    QDBusInterface *m_dbusPhoneInstance;
};

#endif
