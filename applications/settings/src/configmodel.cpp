/*
 *   Copyright 2010 by Marco Martin <mart@kde.org>
 *   Copyright 2011 by Sebastian Kügler <sebas@kde.org>
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

#include "configmodel.h"
#include <QtCore/QTimer>
#include <KConfig>
#include <KConfigGroup>
#include <KDebug>

namespace Plasma
{

class ConfigModelPrivate {

public:
    ConfigModelPrivate(ConfigModel *q):
                  q(q) {}
    ConfigModel* q;
    int maxRoleId;
    //KConfig* config;
    KSharedConfigPtr config;
    KConfigGroup *configGroup;
    QString file;
    QTimer *synchTimer;
    QString group;
    QStringList keys;
    QHash<QString, int> roleIds;

    int countItems() const;
};


ConfigModel::ConfigModel(QObject* parent)
    : QAbstractItemModel(parent),
      d(0)
{
    setObjectName("ConfigModel");
    d = new ConfigModelPrivate(this);
    d->config = 0;
    d->maxRoleId = Qt::UserRole+1;

    QHash<int, QByteArray> roles;
    // DisplayRole is display in QML, consistent with QAIM
    roles.insert(Qt::DisplayRole, "display");
    d->roleIds.insert("display", Qt::DisplayRole);

    roles.insert(d->maxRoleId, "configKey");
    d->roleIds.insert("configKey", d->maxRoleId);
    ++d->maxRoleId;
    roles.insert(d->maxRoleId, "configValue");
    d->roleIds.insert("configValue", d->maxRoleId);
    ++d->maxRoleId;
    setRoleNames(roles);
    kDebug() << "New ConfigModel. " << d->file << d->maxRoleId << d->roleIds;

    // Delay and compress everything within 5 seconds into one sync
    d->synchTimer = new QTimer(this);
    d->synchTimer->setSingleShot(true);
    d->synchTimer->setInterval(5000);
    connect(d->synchTimer, SIGNAL(timeout()), SLOT(sync()));
}

ConfigModel::~ConfigModel()
{
    delete d;
}

QString ConfigModel::file() const
{
    return d->file;
}

void ConfigModel::setFile(const QString& filename)
{
    if (d->file == filename) {
        return;
    }
    d->file = filename;
    readConfigFile();
    emit fileChanged();
}

QString ConfigModel::group() const
{
    return d->group;
}

void ConfigModel::setGroup(const QString& groupname)
{
    if (d->group == groupname) {
        return;
    }
    //readConfigFile();
    d->group = groupname;
    emit groupChanged();
}

bool ConfigModel::readConfigFile()
{
    beginResetModel();

    if (d->file.isEmpty()) {
        return false;
    }
    d->keys.clear();
    kDebug() << "Reading file: " << d->file << d->group;
    d->config = KSharedConfig::openConfig(d->file);
    d->configGroup = new KConfigGroup(d->config, d->group);
    int r = 0;
    bool ok = false;
    foreach (const QString &newkey, d->configGroup->keyList()) {
        d->keys << newkey;
        if (setData(index(r, 0, QModelIndex()), QVariant(newkey), Qt::DisplayRole)) {
            ok = true;
        };
        kDebug() << ok << " set data for: " << r << roleNameToId("configKey") << newkey;
        r++;
    }
    if (ok) { // At least one insert has gone well. :-)
        emit dataChanged(index(0, 0, QModelIndex()),
                         index(r-1, columnCount()-1, QModelIndex()));
        kDebug() << " Groups read: " << d->keys << r-1 << columnCount()-1;
    }
    endResetModel();
    return true;
}

int ConfigModelPrivate::countItems() const
{
    return keys.count();
}


QVariant ConfigModel::data(const QModelIndex &index, int role) const
{
    //kDebug() << "req'ing" << index.row() << index.column() << role;
    if (!index.isValid() || index.column() > 0 ||
        index.row() < 0 || index.row() >= d->countItems()){
        return QVariant();
    }
    const QString &k = d->keys.at(index.row());
    if (role == d->roleIds.value("configValue")) {
        return d->configGroup->readEntry(k, QString("Can't read"));
    } else if (role == Qt::DisplayRole) {
        return "DisplayRole";
    }
    return QVariant(k);
}

QModelIndex ConfigModel::index(int row, int column, const QModelIndex &parent) const
{
    if (parent.isValid() || column > 0 || row < 0 || row >= d->countItems()) {
        return QModelIndex();
    }
    return createIndex(row, column, 0);
}

QModelIndex ConfigModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)

    return QModelIndex();
}

int ConfigModel::rowCount(const QModelIndex &parent) const
{
    //this is not a tree
    //TODO: make it possible some day?
    if (parent.isValid()) {
        return 0;
    }
    return d->countItems();
}

int ConfigModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return 1; // flat list
}

int ConfigModel::roleNameToId(const QString &name)
{
    //kDebug() << d->roleIds.contains(name) << d->roleIds.value(name);
    if (!d->roleIds.contains(name)) {
        return Qt::DisplayRole;
    }
    return d->roleIds.value(name);
}

// Bound methods and slots

bool ConfigModel::writeEntry(const QString& key, const QVariant& value)
{
    kDebug() << " writing setting: " << key << value;
    d->configGroup->writeEntry(key, value);
    d->synchTimer->start();
    //d->configGroup->sync();
    return true;
}

void ConfigModel::sync()
{
    kDebug() << "synching config...";
    d->configGroup->sync();
}

}

#include "configmodel.moc"
