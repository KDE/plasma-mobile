/*
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef SETTINGSCOMPONENT_H
#define SETTINGSCOMPONENT_H

#include <QDeclarativeComponent>

class SettingsComponentPrivate;

class SettingsComponent : public QDeclarativeComponent
{
    Q_OBJECT
    Q_PROPERTY(QString module READ module WRITE setModule NOTIFY moduleChanged)

public:
    SettingsComponent(QDeclarativeEngine *engine = 0, QObject *parent=0);
    ~SettingsComponent();

    QString module() const;
    void setModule(const QString &module);

Q_SIGNALS:
    void moduleChanged();

public Q_SLOTS:
    void loadModule(const QString &name);

private:
    SettingsComponentPrivate* d;
};

#endif
