/****************************************************************************
**
** Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions
** contained in the Technology Preview License Agreement accompanying
** this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
**
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "bytearrayclass.h"

#include <QtScript/QScriptClassPropertyIterator>
#include <QtScript/QScriptEngine>

#include "bytearrayprototype.h"

#include <stdlib.h>

Q_DECLARE_METATYPE(QByteArray*)
Q_DECLARE_METATYPE(ByteArrayClass*)

class ByteArrayClassPropertyIterator : public QScriptClassPropertyIterator
{
public:
    ByteArrayClassPropertyIterator(const QScriptValue &object);
    ~ByteArrayClassPropertyIterator();

    bool hasNext() const;
    void next();

    bool hasPrevious() const;
    void previous();

    void toFront();
    void toBack();

    QScriptString name() const;
    uint id() const;

private:
    int m_index;
    int m_last;
};

//! [0]
ByteArrayClass::ByteArrayClass(QScriptEngine *engine)
    : QObject(engine), QScriptClass(engine)
{
    qScriptRegisterMetaType<QByteArray>(engine, toScriptValue, fromScriptValue);

    length = engine->toStringHandle(QLatin1String("length"));

    proto = engine->newQObject(new ByteArrayPrototype(this),
                               QScriptEngine::QtOwnership,
                               QScriptEngine::SkipMethodsInEnumeration
                               | QScriptEngine::ExcludeSuperClassMethods
                               | QScriptEngine::ExcludeSuperClassProperties);
    QScriptValue global = engine->globalObject();
    proto.setPrototype(global.property("Object").property("prototype"));

    ctor = engine->newFunction(construct, proto);
    ctor.setData(qScriptValueFromValue(engine, this));
}
//! [0]

ByteArrayClass::~ByteArrayClass()
{
}

//! [3]
QScriptClass::QueryFlags ByteArrayClass::queryProperty(const QScriptValue &object,
                                                       const QScriptString &name,
                                                       QueryFlags flags, uint *id)
{
    QByteArray *ba = qscriptvalue_cast<QByteArray*>(object.data());
    if (!ba)
        return 0;
    if (name == length) {
        return flags;
    } else {
        bool isArrayIndex;
        qint32 pos = name.toArrayIndex(&isArrayIndex);
        if (!isArrayIndex)
            return 0;
        *id = pos;
        if ((flags & HandlesReadAccess) && (pos >= ba->size()))
            flags &= ~HandlesReadAccess;
        return flags;
    }
}
//! [3]

//! [4]
QScriptValue ByteArrayClass::property(const QScriptValue &object,
                                      const QScriptString &name, uint id)
{
    QByteArray *ba = qscriptvalue_cast<QByteArray*>(object.data());
    if (!ba)
        return QScriptValue();
    if (name == length) {
        return ba->length();
    } else {
        qint32 pos = id;
        if ((pos < 0) || (pos >= ba->size()))
            return QScriptValue();
        return uint(ba->at(pos)) & 255;
    }
    return QScriptValue();
}
//! [4]

//! [5]
void ByteArrayClass::setProperty(QScriptValue &object,
                                 const QScriptString &name,
                                 uint id, const QScriptValue &value)
{
    QByteArray *ba = qscriptvalue_cast<QByteArray*>(object.data());
    if (!ba)
        return;
    if (name == length) {
        ba->resize(value.toInt32());
    } else {
        qint32 pos = id;
        if (pos < 0)
            return;
        if (ba->size() <= pos)
            ba->resize(pos + 1);
        (*ba)[pos] = char(value.toInt32());
    }
}
//! [5]

//! [6]
QScriptValue::PropertyFlags ByteArrayClass::propertyFlags(
    const QScriptValue &/*object*/, const QScriptString &name, uint /*id*/)
{
    if (name == length) {
        return QScriptValue::Undeletable
            | QScriptValue::SkipInEnumeration;
    }
    return QScriptValue::Undeletable;
}
//! [6]

//! [7]
QScriptClassPropertyIterator *ByteArrayClass::newIterator(const QScriptValue &object)
{
    return new ByteArrayClassPropertyIterator(object);
}
//! [7]

QString ByteArrayClass::name() const
{
    return QLatin1String("ByteArray");
}

QScriptValue ByteArrayClass::prototype() const
{
    return proto;
}

QScriptValue ByteArrayClass::constructor()
{
    return ctor;
}

QScriptValue ByteArrayClass::newInstance(int size)
{
    return newInstance(QByteArray(size, /*ch=*/0));
}

//! [1]
QScriptValue ByteArrayClass::newInstance(const QByteArray &ba)
{
    QScriptValue data = engine()->newVariant(qVariantFromValue(ba));
    return engine()->newObject(this, data);
}
//! [1]

//! [2]
QScriptValue ByteArrayClass::construct(QScriptContext *ctx, QScriptEngine *)
{
    ByteArrayClass *cls = qscriptvalue_cast<ByteArrayClass*>(ctx->callee().data());
    if (!cls)
        return QScriptValue();
    QScriptValue arg = ctx->argument(0);
    if (arg.instanceOf(ctx->callee()))
        return cls->newInstance(qscriptvalue_cast<QByteArray>(arg));
    int size = arg.toInt32();
    return cls->newInstance(size);
}
//! [2]

QScriptValue ByteArrayClass::toScriptValue(QScriptEngine *eng, const QByteArray &ba)
{
    QScriptValue ctor = eng->globalObject().property("ByteArray");
    ByteArrayClass *cls = qscriptvalue_cast<ByteArrayClass*>(ctor.data());
    if (!cls)
        return eng->newVariant(qVariantFromValue(ba));
    return cls->newInstance(ba);
}

void ByteArrayClass::fromScriptValue(const QScriptValue &obj, QByteArray &ba)
{
    ba = obj.toVariant().toByteArray();
}



ByteArrayClassPropertyIterator::ByteArrayClassPropertyIterator(const QScriptValue &object)
    : QScriptClassPropertyIterator(object)
{
    toFront();
}

ByteArrayClassPropertyIterator::~ByteArrayClassPropertyIterator()
{
}

//! [8]
bool ByteArrayClassPropertyIterator::hasNext() const
{
    QByteArray *ba = qscriptvalue_cast<QByteArray*>(object().data());
    return m_index < ba->size();
}

void ByteArrayClassPropertyIterator::next()
{
    m_last = m_index;
    ++m_index;
}

bool ByteArrayClassPropertyIterator::hasPrevious() const
{
    return (m_index > 0);
}

void ByteArrayClassPropertyIterator::previous()
{
    --m_index;
    m_last = m_index;
}

void ByteArrayClassPropertyIterator::toFront()
{
    m_index = 0;
    m_last = -1;
}

void ByteArrayClassPropertyIterator::toBack()
{
    QByteArray *ba = qscriptvalue_cast<QByteArray*>(object().data());
    m_index = ba->size();
    m_last = -1;
}

QScriptString ByteArrayClassPropertyIterator::name() const
{
    return object().engine()->toStringHandle(QString::number(m_last));
}

uint ByteArrayClassPropertyIterator::id() const
{
    return m_last;
}
//! [8]
