/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>
 *   Copyright 2010 by Marco MArtin <mart@kde.org>

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

#include "datasource_p.h"
#include "qdeclarativeengine.h"
#include "qdeclarativecontext.h"

#include <QDebug>
#include <QTimer>

#include <Plasma/Applet>


namespace Plasma
{
DataSource::DataSource(QObject* parent)
    : QObject(parent),
      m_interval(1000),
      m_dataEngine(0)
{
    setObjectName("DataSource");

    m_data = new QDeclarativePropertyMap(this);

    connect(this, SIGNAL(engineChanged()),
            this, SLOT(setupData()));
    connect(this, SIGNAL(sourceChanged()),
            this, SLOT(setupData()));
    connect(this, SIGNAL(intervalChanged()),
            this, SLOT(setupData()));
}

void DataSource::setSource(const QString &s)
{
    if (s == m_source) {
        return;
    }

    m_source = s;
    emit sourceChanged();
}

void DataSource::setupData()
{
    if (/*m_source.isEmpty() ||*/ m_engine.isEmpty()) {
        return;
    }

    if (m_dataEngine) {
        m_dataEngine->disconnectSource(m_connectedSource, this);
        m_dataEngine = 0;
        m_keys.clear();
        emit keysChanged();
    }

    Plasma::DataEngine* de = dataEngine(m_engine);
    if (!de) {
        kWarning() << "DataEngine not found";
        return;
    }

    de->connectSource(m_source, this, m_interval);
    m_dataEngine = de;
    m_connectedSource = m_source;

    connect(de, SIGNAL(sourceAdded(constQString&)), this, SIGNAL(sourcesChanged()));
    connect(de, SIGNAL(sourceRemoved(constQString&)), this, SIGNAL(sourcesChanged()));
}

void DataSource::dataUpdated(const QString &sourceName, const Plasma::DataEngine::Data &data)
{
    Q_UNUSED(sourceName);//Only one source
    QStringList newKeys;

    foreach (const QString &key, data.keys()) {
        // Properties in QML must start lowercase.
        QString ourKey = key.toLower();

        m_data->insert(ourKey.toLatin1(), data.value(key));

        newKeys << ourKey;
    }

    if (newKeys != m_keys) {
        //FIXME: pretty utterly inefficient
        foreach (const QString &key, m_keys) {
            if (!newKeys.contains(key)) {
                m_data->insert(key.toLatin1(), QVariant());
            }
        }

        emit keysChanged();
        m_keys = newKeys;
    }

    emit dataChanged();
}

Plasma::Service *DataSource::service()
{
    if (!m_service) {
        m_service = m_dataEngine->serviceForSource(m_source);
    }

    return m_service;
}

}
#include "datasource_p.moc"
