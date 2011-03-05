/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "plasmainputcontextplugin.h"
#include "inputcontext.h"

#include <QString>
#include <QStringList>
#include <QDebug>


PlasmaInputContextPlugin::PlasmaInputContextPlugin(QObject *parent)
    : QInputContextPlugin(parent)
{
}


PlasmaInputContextPlugin::~PlasmaInputContextPlugin()
{
}


QInputContext *PlasmaInputContextPlugin::create(const QString &key)
{
    QInputContext *context = NULL;
    qDebug()<<"Creating the Plasma input context";

    if (!key.isEmpty()) {
        context = new InputContext();
    }
    return context;
}


QString PlasmaInputContextPlugin::description(const QString &key)
{
    Q_UNUSED(key);

    return "Plasma input context plugin";
}


QString PlasmaInputContextPlugin::displayName(const QString &s)
{
    Q_UNUSED(s);

    return "Input context plugin for Plasma";
}


QStringList PlasmaInputContextPlugin::keys() const
{
    return QStringList("PlasmaInputContext");
}


QStringList PlasmaInputContextPlugin::languages(const QString &)
{
    return QStringList("en_US");
}


Q_EXPORT_PLUGIN2(plasmainputcontextplugin, PlasmaInputContextPlugin)

