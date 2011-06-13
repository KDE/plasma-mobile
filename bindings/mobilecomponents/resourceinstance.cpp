/***************************************************************************
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "resourceinstance.h"

#include <QApplication>

#include <KDE/Activities/ResourceInstance>
#include <KDebug>


ResourceInstance::ResourceInstance(QObject *parent)
    : QObject(parent)
{
}

ResourceInstance::~ResourceInstance()
{

}

QUrl ResourceInstance::uri() const
{
    return m_resourceInstance->uri();
}

void ResourceInstance::setUri(const QUrl &uri)
{
    kDebug()<<"setting current uri:"<<uri;
    //FIXME: this will leak like mad, ResourceInstance should be able to change window
    m_resourceInstance = new Activities::ResourceInstance(QApplication::activeWindow()->winId(), QUrl());
    m_resourceInstance->setUri(uri);
}

QString ResourceInstance::mimetype() const
{
    return m_resourceInstance->mimetype();
}

void ResourceInstance::setMimetype(const QString &mimetype)
{
    m_resourceInstance->setMimetype(mimetype);
}

#include "resourceinstance.moc"

