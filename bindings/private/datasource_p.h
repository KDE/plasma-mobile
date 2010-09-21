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

#ifndef DATASOURCE_H
#define DATASOURCE_H

#include <QObject>


#include <QDeclarativePropertyMap>

#include "dataengineconsumer_p.h"
#include <Plasma/DataEngine>
#include <qdeclarative.h>


class QDeclarativePropertyMap;

namespace Plasma
{
  class Applet;
  class DataEngine;

  class DataSource : public QObject, DataEngineConsumer
  {
      Q_OBJECT
  public:
      typedef QHash<QString, QVariant> Data;
      DataSource(QObject* parent=0);

      Q_PROPERTY(bool valid READ valid);
      bool valid() const {return m_dataEngine != 0;}

      Q_PROPERTY(int interval READ interval WRITE setInterval NOTIFY intervalChanged);
      int interval() const {return m_interval;}
      void setInterval(int i) {if(i==m_interval) return; m_interval=i; emit intervalChanged();}

      Q_PROPERTY(QString engine READ engine WRITE setEngine NOTIFY engineChanged);
      QString engine() const {return m_engine;}
      void setEngine(const QString &e) {if(e==m_engine) return; m_engine=e; emit engineChanged();}

      Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged);
      QString source() const {return m_source;}
      void setSource(const QString &s);

      Q_PROPERTY(QStringList keys READ keys NOTIFY keysChanged);
      QStringList keys() const {return m_keys;}

      Q_PROPERTY(QStringList allSources READ allSources NOTIFY sourcesChanged);
      QStringList allSources() const {if (m_dataEngine) return m_dataEngine->sources(); else return QStringList();}

      Q_PROPERTY(QObject *data READ data NOTIFY dataChanged);
      QObject *data() const {return m_data;}

      Q_PROPERTY(Plasma::Service *service READ service CONSTANT);
      Plasma::Service *service();

  public Q_SLOTS:
      void dataUpdated(const QString &sourceName, const Plasma::DataEngine::Data &data);
      void setupData();

  Q_SIGNALS:
      void intervalChanged();
      void engineChanged();
      void sourceChanged();
      void keysChanged();
      void dataChanged();
      void sourcesChanged();

  private:

      QString m_id;
      int m_interval;
      QString m_source;
      QString m_engine;
      QStringList m_keys;
      QDeclarativePropertyMap *m_data;
      Plasma::DataEngine* m_dataEngine;
      Plasma::Service *m_service;
      QString m_connectedSource;
  };
}
#endif
