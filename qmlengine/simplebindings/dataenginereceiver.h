/*
 *   Copyright 2010 Aaron Seigo <aseigo@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
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

#ifndef DATAENGINERECEIVER_H
#define DATAENGINERECEIVER_H

#include <QScriptValue>

#include <Plasma/DataEngine>

class QScriptContext;
class QScriptEngine;

class DataEngineReceiver : public QObject
{
    Q_OBJECT
public:
    DataEngineReceiver(const Plasma::DataEngine *engine, const QString &source, const QScriptValue &func, QObject *parent);
    ~DataEngineReceiver();

    bool isValid() const;

    static QScriptValue connectSource(QScriptContext *context, QScriptEngine *engine);
    static QScriptValue disconnectSource(QScriptContext *context, QScriptEngine *engine);
    static QSet<DataEngineReceiver*> s_receivers;

    bool matches(const Plasma::DataEngine *engine, const QString &source, const QScriptValue &v);

public Q_SLOTS:
    void dataUpdated(const QString &source, const Plasma::DataEngine::Data &data);

private:
    static DataEngineReceiver *getReceiver(Plasma::DataEngine *dataEngine, const QString &source, const QScriptValue &v);

    const Plasma::DataEngine *m_engine;
    const QString m_source;
    QScriptValue m_func;
    QScriptValue m_obj;
};

#endif // DATAENGINERECEIVER_H

