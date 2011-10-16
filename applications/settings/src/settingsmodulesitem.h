/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#ifndef COMPLETIONITEM_H
#define COMPLETIONITEM_H

#include <QObject>
#include <QIcon>

class SettingsModulesItemPrivate;

class SettingsModulesItem : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString module READ module WRITE setModule NOTIFY moduleChanged)
    Q_PROPERTY(QIcon icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(QString iconName READ iconName WRITE setIconName NOTIFY iconNameChanged)

public:
    SettingsModulesItem(const QString &name = QString(),
             const QString &iconName = QString(),
             const QString &module = QString("org.kde.active.settings.EMPTY"),
             QObject *parent = 0 );
    SettingsModulesItem(QObject *parent);
    ~SettingsModulesItem();

    QString name();
    QString description();
    QString iconName();
    QString module();
    QIcon icon();

public Q_SLOTS:
    void setName(const QString &name);
    void setDescription(const QString &description);
    void setModule(const QString &module);
    void setIcon(const QIcon &icon);
    void setIconName(const QString &iconName);

Q_SIGNALS:
    void nameChanged();
    void descriptionChanged();
    void moduleChanged();
    void iconChanged();
    void iconNameChanged();

private:
    SettingsModulesItemPrivate* d;

};

#endif // COMPLETIONITEM_H
