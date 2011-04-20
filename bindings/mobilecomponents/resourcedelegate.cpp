/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

#include "resourcedelegate.h"

#include <QtDeclarative/QDeclarativeComponent>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeEngine>

#include <kdebug.h>


ResourceDelegate::ResourceDelegate(QDeclarativeItem *parent)
    : QDeclarativeItem(parent),
      m_mainComponent(0),
      m_context(0),
      m_mainObject(0)
{
}

void ResourceDelegate::setMainFile(const QString &file)
{
    m_context = QDeclarativeEngine::contextForObject(this);

    m_mainComponent = new QDeclarativeComponent(m_context->engine(), QUrl::fromLocalFile(file));

    m_mainObject = m_mainComponent->beginCreate(m_context);
    m_mainObject->setParent(this);

    m_context->setContextProperty("plasmoid", this);

    m_mainComponent->completeCreate();
}

QObject *ResourceDelegate::mainObject() const
{
    return m_mainObject;
}


QString ResourceDelegate::resourceType() const
{
    return m_resourceType;
}

void ResourceDelegate::setResourceType(const QString &type)
{
    if (type == m_resourceType) {
        return;
    }

    //TODO: 1) get the file name from a package
    //2) setMainFile()

    emit resourceTypeChanged();
}

QVariantHash ResourceDelegate::data() const
{
    return m_data;
}

void ResourceDelegate::setData(const QVariantHash &data)
{
    m_data = data;
    m_context->setContextProperty("data", data);
    emit dataChanged();
}

#include "resourcedelegate.moc"
