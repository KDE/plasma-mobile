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

#include "metadatausertypes.h"

#include <KLocale>

MetadataUserTypes::MetadataUserTypes(QObject *parent)
    : QObject(parent)
{
    m_typeNames = new QDeclarativePropertyMap;
    m_typeSortFields = new QDeclarativePropertyMap;

    m_userTypes << "nfo:Application";
    m_typeNames->insert("nfo:Application", i18n("Apps"));
    m_typeSortFields->insert("nfo:Application", "nao:prefLabel");

    m_userTypes << "nfo:Bookmark";
    m_typeNames->insert("nfo:Bookmark", i18n("Bookmarks"));
    m_typeSortFields->insert("nfo:Bookmark", "nie:url");

    m_userTypes << "nco:Contact";
    m_typeNames->insert("nco:Contact", i18n("Contacts"));
    m_typeSortFields->insert("nco:Contact", "nco:fullname");

    m_userTypes << "nfo:Document";
    m_typeNames->insert("nfo:Document", i18n("Documents"));
    m_typeSortFields->insert("nfo:Document", "nfo:fileName");

    m_userTypes << "nfo:Image";
    m_typeNames->insert("nfo:Image", i18n("Images"));
    m_typeSortFields->insert("nfo:Image", "nfo:fileName");

    m_userTypes << "nfo:Audio";
    m_typeNames->insert("nfo:Audio", i18n("Music"));
    m_typeSortFields->insert("nfo:Audio", "nfo:fileName");

    m_userTypes << "nfo:Video";
    m_typeNames->insert("nfo:Video", i18n("Videos"));
    m_typeSortFields->insert("nfo:Video", "nfo:fileName");
}

MetadataUserTypes::~MetadataUserTypes()
{
    delete m_typeNames;
    delete m_typeSortFields;
}

QVariantList MetadataUserTypes::userTypes() const
{
    return m_userTypes;
}

QObject *MetadataUserTypes::typeNames() const
{
    return m_typeNames;
}

QObject *MetadataUserTypes::sortFields() const
{
    return m_typeSortFields;
}

#include "metadatausertypes.moc"
