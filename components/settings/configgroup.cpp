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
    QStringList keys;
};


ConfigGroup::ConfigGroup(QObject* parent)
    : QObject(parent),
      d(0)
{
    setObjectName("ConfigModel");
    d = new ConfigGroupPrivate(this);
    d->config = 0;

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
    //readConfigFile();
    d->group = groupname;
    emit groupChanged();
}

QStringList ConfigGroup::keyList() const
{
    return d->keys;
}

void ConfigGroup::setKeyList(const QStringList& keys)
{
    if (d->keys == keys) {
        return;
    }
    //readConfigFile();
    d->keys = keys;
    emit keyListChanged();
}

bool ConfigGroup::readConfigFile()
{
    if (d->file.isEmpty()) {
        return false;
    }
    d->keys.clear();
    kDebug() << "Reading file: " << d->file << d->group;
    d->config = KSharedConfig::openConfig(d->file);
    d->configGroup = new KConfigGroup(d->config, d->group);
    d->keys = d->configGroup->keyList();
    return true;
}

// Bound methods and slots

bool ConfigGroup::writeEntry(const QString& key, const QVariant& value)
{
    kDebug() << " writing setting: " << key << value;
    d->configGroup->writeEntry(key, value);
    d->synchTimer->start();
    //d->configGroup->sync();
    return true;
}

QVariant ConfigGroup::readEntry(const QString& key)
{
    //const QVariant value = d->configGroup->readEntry(key, QString("dEfAuLt"));
    const QVariant value = d->configGroup->readEntry(key, QVariant("dEfAuLt"));
    kDebug() << " reading setting: " << key << value;
    return value;
}

void ConfigGroup::sync()
{
    kDebug() << "synching config...";
    d->configGroup->sync();
}

}

#include "configgroup.moc"
