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

#ifndef COMPLETIONMODEL_H
#define COMPLETIONMODEL_H

#include <QQmlComponent>
#include <QObject>
#include <QImage>

#include "settingsmodule.h"

class History;
class SettingsModulesModelPrivate;

class SettingsModulesModel : public QQmlComponent
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<SettingsModule> settingsModules READ settingsModules NOTIFY settingsModulesChanged)
    Q_PROPERTY(QString application READ application WRITE setApplication NOTIFY applicationChanged)

public:
    SettingsModulesModel(QQmlComponent* parent = 0);
    ~SettingsModulesModel();

    QQmlListProperty<SettingsModule> settingsModules();

    QString application() const;
    void setApplication(const QString &appname);

public Q_SLOTS:
    void populate();

Q_SIGNALS:
    void dataChanged();
    void settingsModulesChanged();
    void applicationChanged();

private:
    SettingsModulesModelPrivate * const d;
};

#endif // COMPLETIONMODEL_H
