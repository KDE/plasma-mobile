/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>

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

#include "datasource.h"
#include "qmlengine.h"
#include "qmlcontext.h"
#include <Plasma/Applet>
#include <QDebug>
#include <QTimer>

QML_DEFINE_TYPE(Plasma, 0, 1, DataSource, DataSource);

DataSource::DataSource(QObject* parent)
    :QObject(parent), m_interval(1000), m_applet(0), m_dataEngine(0)
{
    setObjectName("DataSource");

    m_context = qmlContext(parent);
    connect(this, SIGNAL(engineChanged()),
            this, SLOT(setupData()));
    connect(this, SIGNAL(sourceChanged()),
            this, SLOT(setupData()));
    connect(this, SIGNAL(intervalChanged()),
            this, SLOT(setupData()));
}

void DataSource::setSource(const QString &s)
{
    if(s == m_source)
        return;

    m_source = s;
    emit sourceChanged();
}

void DataSource::setupData()
{
    if(m_source.isEmpty() || m_engine.isEmpty())
        return;
    if(m_dataEngine){
        m_dataEngine->disconnectSource(m_connectedSource, this);
        m_dataEngine = 0;
        m_keys.clear();
        emit keysChanged();
    }

    if(!m_applet){
        //###Why parent() and not this? only parent() works in tests (@61902afefa)
        //QmlBinding val("parent", parent(), qmlContext(parent()));
        //kDebug() << val.expression() << val.value() << QmlContext::activeContext();
        //m_applet = qobject_cast<Plasma::Applet*>(val.value().value<QObject*>());
        QObject *parentObject = parent();
        while (parentObject) {
            //kDebug()<<"walking to"<<parentObject;
            m_applet = qobject_cast<Plasma::Applet*>(parentObject);
            if (!m_applet)
                parentObject = parentObject->parent();
        }
    }

    if(!m_applet){
        kWarning() << "Cannot find applet. DataSources will not work";
        return;
    }
    //kDebug() << "Can find applet. QML Datasources should work";

    Plasma::DataEngine* de = m_applet->dataEngine(m_engine);
    de->connectSource(m_source, this, m_interval);
    m_dataEngine = de;
    m_connectedSource = m_source;
}

void DataSource::dataUpdated(const QString &sourceName, const Plasma::DataEngine::Data &data)
{
    Q_UNUSED(sourceName);//Only one source
    QStringList newKeys;
    foreach(const QString &key, data.keys()){
        /* Note that the data source can't have overlapping properties with
           the DataSource. Also properties in QML must start lowercase.*/
        QString ourKey = key.toLower();
        if(ourKey=="interval" || ourKey=="engine" || ourKey=="source")
            continue;
        //m_dmo->setValue(ourKey.toLatin1(), data.value(key));
        newKeys<<ourKey;
    }

    if(newKeys != m_keys){
        emit keysChanged();
        m_keys = newKeys;
    }
}

#include "datasource.moc"
