/*
 *   Copyright (C) 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// Self
#include "applicationlistmodel.h"

// Qt
#include <QByteArray>
#include <QModelIndex>

// KDE
#include <KPluginInfo>
#include <KRun>
#include <KService>
#include <KServiceTypeTrader>

#include <QDebug>

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    loadApplications();
}

ApplicationListModel::~ApplicationListModel()
{
}

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames[ApplicationNameRole] = "ApplicationNameRole";
    roleNames[ApplicationIconRole] = "ApplicationIconRole";
    roleNames[ApplicationServiceFileRole] = "ApplicationServiceFileRole";

    return roleNames;
}


void ApplicationListModel::loadApplications()
{
    KService::List offers = KServiceTypeTrader::self()->query("Application");
    beginResetModel();
    for(KService::Ptr service : offers) {
        ApplicationData data;
        KPluginInfo plugin(service);
        if (!plugin.property("NoDisplay").toBool() && !plugin.category().contains("System")) {
            data.name = plugin.name();
            data.icon = plugin.icon();
            data.serviceFile = plugin.entryPath();
            m_applicationList << data;
        }
    }
    endResetModel();

    emit countChanged();
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
    case ApplicationNameRole:
        return m_applicationList.at(index.row()).name;
    case ApplicationIconRole:
        return m_applicationList.at(index.row()).icon;
    case ApplicationServiceFileRole:
        return m_applicationList.at(index.row()).serviceFile;
    default:
        return QVariant();
    }
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applicationList.count();
}

void ApplicationListModel::runApplication(int index) {
    if (index <= 0) {
        return;
    }

    KPluginInfo plugin(m_applicationList.at(index).serviceFile);
    KRun::runCommand(m_applicationList.at(index).name.toLower(), 0);
}

#include "applicationlistmodel.moc"
