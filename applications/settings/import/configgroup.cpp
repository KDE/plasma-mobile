/*
 *   Copyright 2011-2012 by Sebastian Kügler <sebas@kde.org>
 *   Copyright 2013 by Aaron Seigo <aseigo@kde.org>
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

#include "configgroup.h"

#include <QtCore/QTimer>
#include <KConfig>
#include <KConfigGroup>
#include <KSharedConfig>
#include <QDebug>

namespace Plasma
{

class ConfigGroupPrivate {

public:
    ConfigGroupPrivate(ConfigGroup *q)
        : q(q),
          config(0),
          configGroup(0)
    {}

    ~ConfigGroupPrivate()
    {
        delete configGroup;
    }

    ConfigGroup* q;
    KSharedConfigPtr config;
    KConfigGroup *configGroup;
    QString file;
    QTimer *syncTimer;
    QString group;
};


ConfigGroup::ConfigGroup(QQuickItem *parent)
    : QQuickItem(parent),
      d(new ConfigGroupPrivate(this))
{
    // Delay and compress everything within 5 seconds into one sync
    d->syncTimer = new QTimer(this);
    d->syncTimer->setSingleShot(true);
    d->syncTimer->setInterval(1500);
    connect(d->syncTimer, &QTimer::timeout, this, &ConfigGroup::sync);
}

ConfigGroup::~ConfigGroup()
{
    if (d->syncTimer->isActive()) {
        qDebug() << "SYNC......";
        d->syncTimer->stop();
        d->configGroup->sync();
    }

    delete d;
}

KConfigGroup* ConfigGroup::configGroup()
{
    return d->configGroup;
}

QString ConfigGroup::file() const
{
    return d->file;
}

void ConfigGroup::setFile(const QString& filename)
{
    if (d->file == filename) {
        return;
    }
    d->file = filename;
    readConfigFile();
    emit fileChanged();
}

QString ConfigGroup::group() const
{
    return d->group;
}

void ConfigGroup::setGroup(const QString& groupname)
{
    if (d->group == groupname) {
        return;
    }
    d->group = groupname;
    qDebug() << "Set group name: " << groupname;
    readConfigFile();
    emit groupChanged();
    emit keyListChanged();
}

QStringList ConfigGroup::keyList() const
{
    if (!d->configGroup) {
        return QStringList();
    }
    return d->configGroup->keyList();
}

QStringList ConfigGroup::groupList() const
{
    return d->configGroup->groupList();
}

bool ConfigGroup::readConfigFile()
{
    // Find parent ConfigGroup
    ConfigGroup* parentGroup = 0;
    QObject* current = parent();
    while (current) {
        parentGroup = qobject_cast<ConfigGroup*>(current);
        if (parentGroup) {
            break;
        }
        current = current->parent();
    }

    delete d->configGroup;
    d->configGroup = 0;

    if (parentGroup) {
        d->configGroup = new KConfigGroup(parentGroup->configGroup(), d->group);
        return true;
    } else {
        if (d->file.isEmpty()) {
            //qWarning() << "Could not find KConfig Parent: specify a file or parent to another ConfigGroup";
            return false;
        }
        d->config = KSharedConfig::openConfig(d->file);
        d->configGroup = new KConfigGroup(d->config, d->group);
        qDebug() << "Opened config" << d->configGroup->entryMap();

        return true;
    }
}

// Bound methods and slots

bool ConfigGroup::writeEntry(const QString& key, const QVariant& value)
{
    if (!d->configGroup) {
        return false;
    }

    d->configGroup->writeEntry(key, value);
    d->syncTimer->start();
    return true;
}

QVariant ConfigGroup::readEntry(const QString& key)
{
    if (!d->configGroup) {
        return QVariant();
    }
    const QVariant value = d->configGroup->readEntry(key, QVariant(""));
    qDebug() << " reading setting: " << key << value;
    return value;
}

void ConfigGroup::deleteEntry(const QString& key)
{
    d->configGroup->deleteEntry(key);
    d->syncTimer->start();
}

void ConfigGroup::sync()
{
    if (d->configGroup) {
        qDebug() << "synching config...";
        d->configGroup->sync();
    }
}

} // namespace Plasma
#include "configgroup.moc"
