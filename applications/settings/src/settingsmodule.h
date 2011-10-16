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

#ifndef SETTINGSMODULE_H
#define SETTINGSMODULE_H

#include <kdemacros.h>
#include <QObject>
#include <QVariant>

class SettingsModulePrivate;

class KDE_EXPORT SettingsModule : public QObject
{
    Q_OBJECT

    public:
        SettingsModule(QObject *parent, const QVariantList &v);
        virtual ~SettingsModule();

        /**
         * @return Settings object exported by the plugin, which is made
         * available to the QML UI parts
         */
        virtual QObject* settingsObject();

        QString name();

        /**
         * @internal Uses to transfer data and settings between QML package and C++ plugin.
         */
        void setSettingsObject(QObject *o);

    private:
        SettingsModulePrivate *d;

};

#endif
