/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtDeclarative module of the Qt Toolkit.
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

#ifndef QDECLARATIVEOPENMETAOBJECT_H
#define QDECLARATIVEOPENMETAOBJECT_H

#include <private/qdeclarativerefcount_p.h>
#include <QtCore/QMetaObject>
#include <QtCore/QObject>

#include <private/qobject_p.h>

QT_BEGIN_HEADER

QT_BEGIN_NAMESPACE

QT_MODULE(Declarative)

class QDeclarativeEngine;
class QMetaPropertyBuilder;
class QDeclarativeOpenMetaObjectTypePrivate;
class Q_DECLARATIVE_EXPORT QDeclarativeOpenMetaObjectType : public QDeclarativeRefCount
{
public:
    QDeclarativeOpenMetaObjectType(const QMetaObject *base, QDeclarativeEngine *engine);
    ~QDeclarativeOpenMetaObjectType();

    int createProperty(const QByteArray &name);

    int propertyOffset() const;
    int signalOffset() const;

protected:
    virtual void propertyCreated(int, QMetaPropertyBuilder &);

private:
    QDeclarativeOpenMetaObjectTypePrivate *d;
    friend class QDeclarativeOpenMetaObject;
    friend class QDeclarativeOpenMetaObjectPrivate;
};

class QDeclarativeOpenMetaObjectPrivate;
class Q_DECLARATIVE_EXPORT QDeclarativeOpenMetaObject : public QAbstractDynamicMetaObject
{
public:
    QDeclarativeOpenMetaObject(QObject *, bool = true);
    QDeclarativeOpenMetaObject(QObject *, QDeclarativeOpenMetaObjectType *, bool = true);
    ~QDeclarativeOpenMetaObject();

    QVariant value(const QByteArray &) const;
    void setValue(const QByteArray &, const QVariant &);
    QVariant value(int) const;
    void setValue(int, const QVariant &);
    QVariant &operator[](const QByteArray &);
    QVariant &operator[](int);

    int count() const;
    QByteArray name(int) const;

    QObject *object() const;
    virtual QVariant initialValue(int);

    // Be careful - once setCached(true) is called createProperty() is no
    // longer automatically called for new properties.
    void setCached(bool);

    QDeclarativeOpenMetaObjectType *type() const;

protected:
    virtual int metaCall(QMetaObject::Call _c, int _id, void **_a);
    virtual int createProperty(const char *, const char *);

    virtual void propertyRead(int);
    virtual void propertyWrite(int);
    virtual void propertyWritten(int);
    virtual void propertyCreated(int, QMetaPropertyBuilder &);

    QAbstractDynamicMetaObject *parent() const;

private:
    QDeclarativeOpenMetaObjectPrivate *d;
    friend class QDeclarativeOpenMetaObjectType;
};

QT_END_NAMESPACE

QT_END_HEADER

#endif // QDECLARATIVEOPENMETAOBJECT_H
