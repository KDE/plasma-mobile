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

#include <QtScript/QScriptValue>
#include <QtScript/QScriptEngine>
#include <QtScript/QScriptContext>
#include <KUrl>
#include <KDebug>
#include "backportglobal.h"

Q_DECLARE_METATYPE(KUrl*)
//Q_DECLARE_METATYPE(KUrl) unneeded; found in kurl.h

static QScriptValue ctor(QScriptContext *ctx, QScriptEngine *eng)
{
    if (ctx->argumentCount() == 1)
    {
        QString url = ctx->argument(0).toString();
        return qScriptValueFromValue(eng, KUrl(url));
    }

    return qScriptValueFromValue(eng, KUrl());
}

static QScriptValue toString(QScriptContext *ctx, QScriptEngine *eng)
{
    DECLARE_SELF(KUrl, toString);
    return QScriptValue(eng, self->prettyUrl());
}

static QScriptValue protocol(QScriptContext *ctx, QScriptEngine *eng)
{
    DECLARE_SELF(KUrl, protocol);
    if (ctx->argumentCount()) {
        QString v = ctx->argument(0).toString();
        self->setProtocol(v);
    }

    return QScriptValue(eng, self->protocol());
}

static QScriptValue host(QScriptContext *ctx, QScriptEngine *eng)
{
    DECLARE_SELF(KUrl, protocol);
    if (ctx->argumentCount()) {
        QString v = ctx->argument(0).toString();
        self->setHost(v);
    }

    return QScriptValue(eng, self->host());
}

static QScriptValue path(QScriptContext *ctx, QScriptEngine *eng)
{
    DECLARE_SELF(KUrl, path);
    if (ctx->argumentCount()) {
        QString v = ctx->argument(0).toString();
        self->setPath(v);
    }

    return QScriptValue(eng, self->path());
}

static QScriptValue user(QScriptContext *ctx, QScriptEngine *eng)
{
    DECLARE_SELF(KUrl, user);
    if (ctx->argumentCount()) {
        QString v = ctx->argument(0).toString();
        self->setUser(v);
    }

    return QScriptValue(eng, self->user());
}

static QScriptValue password(QScriptContext *ctx, QScriptEngine *eng)
{
    DECLARE_SELF(KUrl, password);
    if (ctx->argumentCount()) {
        QString v = ctx->argument(0).toString();
        self->setPassword(v);
    }

    return QScriptValue(eng, self->password());
}

QScriptValue constructKUrlClass(QScriptEngine *eng)
{
    QScriptValue proto = qScriptValueFromValue(eng, KUrl());
    QScriptValue::PropertyFlags getter = QScriptValue::PropertyGetter;
    QScriptValue::PropertyFlags setter = QScriptValue::PropertySetter;

    proto.setProperty("toString", eng->newFunction(toString), getter);
    proto.setProperty("protocol", eng->newFunction(protocol), getter | setter);
    proto.setProperty("host", eng->newFunction(host), getter | setter);
    proto.setProperty("path", eng->newFunction(path), getter | setter);
    proto.setProperty("user", eng->newFunction(user), getter | setter);
    proto.setProperty("password", eng->newFunction(password), getter | setter);

    eng->setDefaultPrototype(qMetaTypeId<KUrl*>(), proto);
    eng->setDefaultPrototype(qMetaTypeId<KUrl>(), proto);

    return eng->newFunction(ctor, proto);
}

//Those are used only for QML

QScriptValue qScriptValueFromKUrl(QScriptEngine *eng, const KUrl &url)
{
    QScriptValue obj = eng->newVariant(url);
    QScriptValue::PropertyFlags getter = QScriptValue::PropertyGetter;
    QScriptValue::PropertyFlags setter = QScriptValue::PropertySetter;

    obj.setProperty("toString", eng->newFunction(toString), getter);
    obj.setProperty("protocol", eng->newFunction(protocol), getter | setter);
    obj.setProperty("host", eng->newFunction(host), getter | setter);
    obj.setProperty("path", eng->newFunction(path), getter | setter);
    obj.setProperty("user", eng->newFunction(user), getter | setter);
    obj.setProperty("password", eng->newFunction(password), getter | setter);

    return obj;
}

void kUrlFromScriptValue(const QScriptValue& obj, KUrl &url)
{
    url = qscriptvalue_cast<KUrl>(obj);
}

void registerUrlMetaType(QScriptEngine *engine)
{
    qScriptRegisterMetaType<KUrl>(engine, qScriptValueFromKUrl, kUrlFromScriptValue, QScriptValue());
}
