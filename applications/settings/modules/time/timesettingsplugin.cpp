/*
    Copyright 2005 S.R.Haque <srhaque@iee.org>.
    Copyright 2009 David Faure <faure@kde.org>
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This file is part of the KDE project

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License version 2, as published by the Free Software Foundation.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "timesettingsplugin.h"
#include "timesettings.h"
#include "timezone.h"
#include "timezonesmodel.h"

#include <QDebug>
#include <KIcon>
#include <KLocale>

#include <QStandardItemModel>
#include <QTimer>
#include <QVariant>

#include <KPluginFactory>
#include <KTimeZone>

#include <QtQml>
#include <QtCore/QDate>

K_PLUGIN_FACTORY_WITH_JSON(TimeSettingsFactory, "metadata.json", registerPlugin<TimeSettingsPlugin>();)

#define FORMAT24H "%H:%M:%S"
#define FORMAT12H "%l:%M:%S %p"

TimeSettingsPlugin::TimeSettingsPlugin(QObject *parent, const QVariantList &list)
    : QObject(parent)
{
    Q_UNUSED(list)

  //    qmlRegisterType<TimeZone>("org.kde.active.settings.time", 2, 0, "TimeZone");
    qmlRegisterType<TimeSettings>("org.kde.active.settings.time", 2, 0, "TimeSettings");
    qDebug() << "TimeSettingsPlugin registered types :)";
}

TimeSettingsPlugin::~TimeSettingsPlugin()
{
    qDebug() << "ts plugin del'ed";
}


#include "timesettingsplugin.moc"
