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

#include <QQuickItem>

class SettingsComponentPrivate;

class SettingsComponent : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString module READ module WRITE setModule NOTIFY moduleChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(bool valid READ isValid NOTIFY validChanged)

public:
    SettingsComponent(QQuickItem *parent = 0);
    ~SettingsComponent();

    QString description() const;

    QString module() const;
    QString name() const;
    QString icon() const;

    bool isValid() const;

Q_SIGNALS:
    void descriptionChanged();
    void moduleChanged();
    void nameChanged();
    void iconChanged();
    void validChanged();

public Q_SLOTS:
    void setModule(const QString &module);
    void setDescription(const QString &description);
    void setName(const QString &name);
    void setIcon(const QString &name);

    void loadModule(const QString &name);

private:
    SettingsComponentPrivate* d;
};

#endif
