/*
 *   Copyright 2007 Richard J. Moore <rich@kde.org>
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

#include "dataengine.h"

typedef Plasma::Service *ServicePtr;
QScriptValue qScriptValueFromService(QScriptEngine *engine, const ServicePtr &service)
{
    return engine->newQObject(const_cast<Plasma::Service *>(service), QScriptEngine::AutoOwnership, QScriptEngine::PreferExistingWrapperObject);
}

void serviceFromQScriptValue(const QScriptValue &scriptValue, ServicePtr &service)
{
    QObject *obj = scriptValue.toQObject();
    service = static_cast<Plasma::Service *>(obj);
}

typedef Plasma::DataEngine *DataEnginePtr;
QScriptValue qScriptValueFromDataEngine(QScriptEngine *engine, const DataEnginePtr &dataEngine)
{
    return engine->newQObject(const_cast<Plasma::DataEngine *>(dataEngine), QScriptEngine::AutoOwnership, QScriptEngine::PreferExistingWrapperObject);
}

void dataEngineFromQScriptValue(const QScriptValue &scriptValue, DataEnginePtr &dataEngine)
{
    QObject *obj = scriptValue.toQObject();
    dataEngine = static_cast<Plasma::DataEngine *>(obj);
}

typedef Plasma::ServiceJob *ServiceJobPtr;
QScriptValue qScriptValueFromServiceJob(QScriptEngine *engine, const ServiceJobPtr &serviceJob)
{
    return engine->newQObject(const_cast<Plasma::ServiceJob *>(serviceJob), QScriptEngine::AutoOwnership, QScriptEngine::PreferExistingWrapperObject);
}

void serviceJobFromQScriptValue(const QScriptValue &scriptValue, ServiceJobPtr &serviceJob)
{
    QObject *obj = scriptValue.toQObject();
    serviceJob = static_cast<Plasma::ServiceJob *>(obj);
}

void registerDataEngineMetaTypes(QScriptEngine *engine)
{
    qRegisterMetaType<Plasma::DataEngine::Data>("Plasma::DataEngine::Data");
    qRegisterMetaType<Plasma::DataEngine::Data>("DataEngine::Data");
    qScriptRegisterMapMetaType<Plasma::DataEngine::Data>(engine);
    qScriptRegisterMetaType<Plasma::Service *>(engine, qScriptValueFromService, serviceFromQScriptValue);
    qScriptRegisterMetaType<Plasma::DataEngine *>(engine, qScriptValueFromDataEngine, dataEngineFromQScriptValue);
    qScriptRegisterMetaType<Plasma::ServiceJob *>(engine, qScriptValueFromServiceJob, serviceJobFromQScriptValue);
}

