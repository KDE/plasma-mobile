/*
 *   Copyright 2011-2012 by Sebastian Kügler <sebas@kde.org>
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
#include <KDebug>

namespace Plasma
{

class ConfigGroupPrivate {

public:
    ConfigGroupPrivate(ConfigGroup *q):
                  q(q) {}
    ConfigGroup* q;
    KSharedConfigPtr config;
    KConfigGroup *configGroup;
    QString file;
    QTimer *synchTimer;
    QString group;
};


ConfigGroup::ConfigGroup(QDeclarativeItem* parent)
    : QDeclarativeItem(parent),
      d(0)
{
    setObjectName("ConfigModel");
    d = new ConfigGroupPrivate(this);
    d->config = 0;
    d->configGroup = 0;

    // Delay and compress everything within 5 seconds into one sync
    d->synchTimer = new QTimer(this);
    d->synchTimer->setSingleShot(true);
    d->synchTimer->setInterval(5000);
    connect(d->synchTimer, SIGNAL(timeout()), SLOT(sync()));
}

ConfigGroup::~ConfigGroup()
{
    if (d->synchTimer->isActive()) {
        kDebug() << "SYNC......";
        d->synchTimer->stop();
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
        parentGroup = dynamic_cast<ConfigGroup*>(current);
        if (parentGroup) {
            break;
        }
        current = current->parent();
    }
    if (parentGroup) {
        d->configGroup = new KConfigGroup(parentGroup->configGroup(), d->group);
        return true;
    } else {
        if (d->file.isEmpty()) {
            kWarning() << "Could not find KConfig Parent: specify a file or parent to another ConfigGroup";
            return false;
        }
        d->config = KSharedConfig::openConfig(d->file);
        d->configGroup = new KConfigGroup(d->config, d->group);
        return true;
    }
}

// Bound methods and slots

bool ConfigGroup::writeEntry(const QString& key, const QVariant& value)
{
    if (!d->configGroup) {
        return false;
    }
    //kDebug() << " writing setting: " << key << value;
    d->configGroup->writeEntry(key, value);
    d->synchTimer->start();
    return true;
}

QVariant ConfigGroup::readEntry(const QString& key)
{
    if (!d->configGroup) {
        return QVariant();
    }
    const QVariant value = d->configGroup->readEntry(key, QVariant(""));
    //kDebug() << " reading setting: " << key << value;
    return value;
}

void ConfigGroup::deleteEntry(const QString& key)
{
    d->configGroup->deleteEntry(key);
}

void ConfigGroup::sync()
{
    if (d->configGroup) {
        //kDebug() << "synching config...";
        d->configGroup->sync();
    }
}

}

#include "configgroup.moc"
