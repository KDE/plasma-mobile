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

#ifndef RESOURCEDELEGATE_H
#define RESOURCEDELEGATE_H

#include <QDeclarativeItem>
#include <QtDeclarative/QDeclarativeComponent>

#include <QVariantHash>

class QDeclarativeComponent;
class QDeclarativeContext;

class ResourceDelegate : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(QString resourceType READ resourceType WRITE setResourceType)

public:
    ResourceDelegate(QDeclarativeItem *parent = 0);

    QString resourceType() const;
    void setResourceType(const QString &plugin);

    QVariantHash data() const;
    void setData(const QVariantHash &data);

    QObject *mainObject() const;

protected:
    void setMainFile(const QString &file);

Q_SIGNALS:
    void resourceTypeChanged();
    void dataChanged();

private Q_SLOTS:
    void statusChanged(QDeclarativeComponent::Status);

private:
    QDeclarativeComponent *m_mainComponent;
    QDeclarativeContext *m_context;
    QObject *m_mainObject;
    QString m_resourceType;
    QVariantHash m_data;
};

#endif
