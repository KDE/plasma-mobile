/*
 *   Copyright 2010 Aaron J. Seigo <aseigo@kde.org>
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

#include "dataenginereceiver.h"

#include <QScriptEngine>

#include "dataengine.h"
#include "scriptenv.h"

QSet<DataEngineReceiver*> DataEngineReceiver::s_receivers;

DataEngineReceiver::DataEngineReceiver(const Plasma::DataEngine *engine, const QString &source, const QScriptValue &func, QObject *parent)
    : QObject(parent),
      m_engine(engine),
      m_source(source),
      m_func(func),
      m_obj(m_func)
{
    s_receivers.insert(this);
    if (!m_func.isFunction()) {
        QScriptValue func = m_func.property("dataUpdated");
        if (func.isFunction()) {
            m_func = func;
        } else {
            m_obj = QScriptValue();
        }
    }
}

DataEngineReceiver::~DataEngineReceiver()
{
    s_receivers.remove(this);
    //kDebug() << s_receivers.count();
}

bool DataEngineReceiver::isValid() const
{
    return m_obj.isValid();
}

bool DataEngineReceiver::matches(const Plasma::DataEngine *engine, const QString &source, const QScriptValue &v)
{
    return engine == m_engine && m_source == source && v.equals(m_obj);
}

void DataEngineReceiver::dataUpdated(const QString &source, const Plasma::DataEngine::Data &data)
{
    QScriptEngine *engine = m_func.engine();
//    QScriptValue appletValue = engine->globalObject().property("plasmoid");
    QScriptValueList args;
    args << source;
    args << qScriptValueFromMap<Plasma::DataEngine::Data>(engine, data);

    m_func.call(m_obj, args);

    if (engine->hasUncaughtException()) {
        ScriptEnv *env = ScriptEnv::findScriptEnv(engine);
        env->checkForErrors(false);
    }
}

DataEngineReceiver *DataEngineReceiver::getReceiver(Plasma::DataEngine *dataEngine, const QString &source, const QScriptValue &v)
{
    foreach (DataEngineReceiver *receiver, DataEngineReceiver::s_receivers) {
        if (receiver->matches(dataEngine, source, v)) {
            return receiver; 
        }
    }

    return 0;
}

QScriptValue DataEngineReceiver::connectSource(QScriptContext *context, QScriptEngine *engine)
{
    if (context->argumentCount() < 2) {
        return engine->undefinedValue();
    }

    DataEngine *dataEngine = qobject_cast<DataEngine *>(context->thisObject().toQObject());
    if (!dataEngine) {
        return engine->undefinedValue();
    }

    const QString source = context->argument(0).toString();
    if (source.isEmpty()) {
        return engine->undefinedValue();
    }

    QObject *obj = 0;
    QScriptValue v = context->argument(1);
    // if it's a function we get, then use that directly
    // next see if it is a qobject with a good slot; if it is then use that directly
    // otherwise, try to use the object with a dataUpdated method call
    if (v.isFunction()) {
        obj = getReceiver(dataEngine, source, v);
        if (!obj) {
            obj = new DataEngineReceiver(dataEngine, source, v, ScriptEnv::findScriptEnv(engine));
        }
    } else if (v.isObject()) {
        obj = v.toQObject();
        if (!obj || obj->metaObject()->indexOfSlot("dataUpdated(QString,Plasma::DataEngine::Data)") == -1) {
            obj = getReceiver(dataEngine, source, v);
            if (!obj) {
                DataEngineReceiver *receiver = new DataEngineReceiver(dataEngine, source, v, ScriptEnv::findScriptEnv(engine));
                if (receiver->isValid()) {
                    obj = receiver;
                } else {
                    delete receiver;
                }
            }
        }
    }

    if (!obj) {
        return engine->undefinedValue();
    }

    int pollingInterval = 0;
    Plasma::IntervalAlignment intervalAlignment = Plasma::NoAlignment;
    if (context->argumentCount() > 2) {
        pollingInterval = context->argument(2).toInt32();

        if (context->argumentCount() > 3) {
            intervalAlignment = static_cast<Plasma::IntervalAlignment>(context->argument(4).toInt32());
        }
    }

    dataEngine->connectSource(source, obj, pollingInterval, intervalAlignment);
    return true;
}

QScriptValue DataEngineReceiver::disconnectSource(QScriptContext *context, QScriptEngine *engine)
{
    if (context->argumentCount() < 2) {
        return engine->undefinedValue();
    }

    DataEngine *dataEngine = qobject_cast<DataEngine *>(context->thisObject().toQObject());
    if (!dataEngine) {
        //kDebug() << "no engine!";
        return engine->undefinedValue();
    }

    const QString source = context->argument(0).toString();
    if (source.isEmpty()) {
        //kDebug() << "no source!";
        return engine->undefinedValue();
    }

    QObject *obj = 0;
    QScriptValue v = context->argument(1);
    if (v.isQObject()) {
        obj = v.toQObject();
    } else if (v.isObject() || v.isFunction()) {
        foreach (DataEngineReceiver *receiver, DataEngineReceiver::s_receivers) {
            if (receiver->matches(dataEngine, source, v)) {
                obj = receiver;
                receiver->deleteLater();
                break;
            }
        }
    }

    if (!obj) {
        //kDebug() << "no object!";
        return engine->undefinedValue();
    }

    dataEngine->disconnectSource(source, obj);
    return true;
}

#include "dataenginereceiver.moc"

