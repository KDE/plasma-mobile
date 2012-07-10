/*
    Copyright 2011 Marco Martin <mart@kde.org>
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301, USA.
*/

#ifndef RESOURCECONTAINER_H
#define RESOURCECONTAINER_H

#include <Plasma/DataContainer>

#include <Nepomuk2/Resource>
#include <Nepomuk2/ResourceWatcher>

namespace Nepomuk {
    class ResourceWatcher;
}


class ResourceContainer : public Plasma::DataContainer
{
    Q_OBJECT

public:
    ResourceContainer(QObject *parent = 0);
    ~ResourceContainer();

    void setResource(Nepomuk2::Resource resource);

protected Q_SLOTS:
    void propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property, QVariant);

protected:
    QString icon(const QStringList &types);
    void doQuery();

private:
    Nepomuk2::ResourceWatcher* m_watcher;
    Nepomuk2::Resource m_resource;
    QHash<QString, QString> m_icons;
};

#endif
