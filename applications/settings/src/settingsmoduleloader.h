/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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


#include <QObject>

class SettingsModule;

class SettingsModuleLoader : public QObject
{
    Q_OBJECT
    public:
        SettingsModuleLoader(QObject* parent);
        virtual ~SettingsModuleLoader();

        void loadAllPlugins(const QString &pluginName = QString());

    Q_SIGNALS:
        void pluginLoaded(SettingsModule* plugin);

    private:
        SettingsModule* m_plugin;
        QString m_pluginName;
};