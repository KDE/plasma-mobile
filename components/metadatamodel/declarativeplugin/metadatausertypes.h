/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef METADATAUSERTYPES_H
#define METADATAUSERTYPES_H

#include <QObject>
#include <QDeclarativePropertyMap>


/**
 * class that contains all nepomuk types considered to be user friendly and presentable to the user, complete with a localized name
 *
 * @author Marco Martin <mart@kde.org>
 */
class MetadataUserTypes : public QObject
{
    Q_OBJECT
    /**
     * @property Array of the types that are considered to be presentable to the user, in a form such as nfo:Application
     */
    Q_PROPERTY(QVariantList userTypes READ userTypes CONSTANT)

    /**
     * @property Object Associative array that maps from types to their localized, user facing name
     */
    Q_PROPERTY(QObject *typeNames READ typeNames CONSTANT)

    /**
     * @property Object Associative array that maps from type to the property that should be used to sort the results of a query
     */
    Q_PROPERTY(QObject *sortFields READ sortFields CONSTANT)

public:
    MetadataUserTypes(QObject *parent = 0);
    ~MetadataUserTypes();

    QVariantList userTypes() const;
    QObject *typeNames() const;
    QObject *sortFields() const;

private:
    QDeclarativePropertyMap *m_typeNames;
    QDeclarativePropertyMap *m_typeSortFields;
    QVariantList m_userTypes;
};

#endif
