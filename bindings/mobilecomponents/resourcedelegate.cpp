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


#include <QFile>
#include <QtDeclarative/QDeclarativeComponent>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeEngine>

#include <KStandardDirs>
#include <KDebug>


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
    connect(m_mainComponent, SIGNAL(statusChanged(QDeclarativeComponent::Status)),
                             SLOT(statusChanged(QDeclarativeComponent::Status)));
    m_mainObject = m_mainComponent->beginCreate(m_context);

    if (!m_mainObject) {
        return;
    }

    QGraphicsObject *qgo = qobject_cast<QDeclarativeItem *>(m_mainObject);
    if (qgo) {
        qgo->setParentItem(this);
    } else {
        m_mainObject->setParent(this);
    }

    m_mainComponent->completeCreate();
}

QObject *ResourceDelegate::mainObject() const
{
    return m_mainObject;
}

void ResourceDelegate::statusChanged(QDeclarativeComponent::Status status)
{
    if (status == QDeclarativeComponent::Error) {
        kDebug() << "ERROR!!!!!";
        foreach(QDeclarativeError e, m_mainComponent->errors()) {
            kWarning() << "EE:" << e.url().toString() <<
                            " line: " << e.line() <<
                            " col: " << e.column() <<
                            " Error: " << e.toString();
            
        }
        // FIXME: pass it on to the item, so the error can somehow be handled
    }
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

    //Attempt to understand if we are in an itemview and what kind of
    //default to ListView
    QString fileName = "ListViewItem.qml";
    QDeclarativeItem *par = property("parent").value<QDeclarativeItem *>();
    if (par) {
        par = par->property("parent").value<QDeclarativeItem *>();
    }
    if (par) {
        const QString className = par->metaObject()->className();
        if (className == "QDeclarativeGridView") {
            fileName = "GridView.qml";
        } else if (className == "QDeclarativePathView") {
            fileName = "PathView.qml";
        }
    }

    /* TODO:
    * should it use a Package?
    */
    QString path =
        KStandardDirs::locate("data", "plasma/resourcedelegates/" + type.split('#').last() + "/" + fileName );

    //fallback to FileDataObject
    // TODO: we want cascading fallback from the most specific resource type
    // to the more generic one, trueg can give us API for those, we'll basically
    // want a sorted QStringList from most specific to most generic ontology, so
    // we can always load the best matching resource delegate. -- sebas
    if (!QFile::exists(path)) {
        path = KStandardDirs::locate("data", "plasma/resourcedelegates/FileDataObject/"+fileName );
    }
    setMainFile(path);

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
