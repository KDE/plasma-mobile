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
    m_userTypes << "nfo:bookmark";
    m_typeNames->insert("nfo:bookmark", i18n("Bookmarks"));
    m_userTypes << "nco:contact";
    m_typeNames->insert("nco:contact", i18n("Contacts"));
    m_userTypes << "nfo:document";
    m_typeNames->insert("nfo:document", i18n("Documents"));
    m_userTypes << "nfo:image";
    m_typeNames->insert("nfo:image", i18n("Images"));
    m_userTypes << "nfo:audio";
    m_typeNames->insert("nfo:audio", i18n("Music"));
    m_userTypes << "nfo:video";
    m_typeNames->insert("nfo:video", i18n("Videos"));
}

MetadataUserTypes::~MetadataUserTypes()
{
    delete m_typeNames;
}

QVariantList MetadataUserTypes::userTypes() const
{
    return m_userTypes;
}

QDeclarativePropertyMap *MetadataUserTypes::typeNames() const
{
    return m_typeNames;
}


#include "metadatausertypes.moc"
