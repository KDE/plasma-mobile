/*
 *   Copyright (c) 2009 Aaron J. Seigo <aseigo@kde.org>
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

#include <KIcon>

#include "backportglobal.h"

Q_DECLARE_METATYPE(QIcon)
Q_DECLARE_METATYPE(QIcon*)
Q_DECLARE_METATYPE(KIcon)
Q_DECLARE_METATYPE(KIcon*)

static QScriptValue ctor(QScriptContext *ctx, QScriptEngine *eng)
{
    if (ctx->argumentCount() > 0) {
        QScriptValue v = ctx->argument(0);
        if (v.isString()) {
            QIcon icon = KIcon(v.toString());
            return qScriptValueFromValue(eng, icon);
        } else if (v.isVariant()) {
            QVariant variant = v.toVariant();
            QPixmap p = variant.value<QPixmap>();
            if (!p.isNull()) {
                return qScriptValueFromValue(eng, QIcon(p));
            }
        }
    }
    return qScriptValueFromValue(eng, QIcon());
}

static QScriptValue addPixmap(QScriptContext *ctx, QScriptEngine *eng)
{
    DECLARE_SELF(QIcon, addPixmap);

    if (ctx->argumentCount() > 0) {
        QScriptValue arg = ctx->argument(0);

        if (arg.isVariant()) {
            QVariant variant = arg.toVariant();
            QPixmap p = variant.value<QPixmap>();
            if (!p.isNull()) {
                self->addPixmap(p);
            }
        }
    }

    return eng->undefinedValue();
}

static QScriptValue addFile(QScriptContext *ctx, QScriptEngine *eng)
{
    DECLARE_SELF(QIcon, addFile);

    if (ctx->argumentCount() > 0) {
        QScriptValue arg = ctx->argument(0);

        if (arg.isString()) {
            self->addFile(arg.toString());
        }
    }

    return eng->undefinedValue();
}

static QScriptValue isNull(QScriptContext *ctx, QScriptEngine *eng)
{
    Q_UNUSED(eng)
    DECLARE_SELF(QIcon, isNull);
    return self->isNull();
}

QScriptValue constructIconClass(QScriptEngine *eng)
{
    QScriptValue proto = qScriptValueFromValue(eng, QIcon());
    QScriptValue::PropertyFlags getter = QScriptValue::PropertyGetter;
    QScriptValue::PropertyFlags setter = QScriptValue::PropertySetter;
    proto.setProperty("addPixmap", eng->newFunction(addPixmap));
    proto.setProperty("addFile", eng->newFunction(addFile));
    proto.setProperty("null", eng->newFunction(isNull), getter);

    QScriptValue ctorFun = eng->newFunction(ctor, proto);
    ADD_ENUM_VALUE(ctorFun, QIcon, Normal);
    ADD_ENUM_VALUE(ctorFun, QIcon, Disabled);
    ADD_ENUM_VALUE(ctorFun, QIcon, Active);
    ADD_ENUM_VALUE(ctorFun, QIcon, Selected);
    ADD_ENUM_VALUE(ctorFun, QIcon, Off);
    ADD_ENUM_VALUE(ctorFun, QIcon, On);

    eng->setDefaultPrototype(qMetaTypeId<QIcon>(), proto);

    return ctorFun;
}

