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

#include <QColor>
#include <QDate>
#include <QDateTime>
#include <QScriptEngine>
#include <QScriptValue>
#include <QVariant>

#include <KUrl>

QScriptValue variantToScriptValue(QScriptEngine *engine, QVariant var)
{
    if (var.isNull()) {
        return engine->nullValue();
    }

    switch(var.type())
    {
        case QVariant::Invalid:
            return engine->nullValue();
        case QVariant::Bool:
            return QScriptValue(engine, var.toBool());
        case QVariant::Date:
            return engine->newDate(var.toDateTime());
        case QVariant::DateTime:
            return engine->newDate(var.toDateTime());
        case QVariant::Double:
            return QScriptValue(engine, var.toDouble());
        case QVariant::Int:
        case QVariant::LongLong:
            return QScriptValue(engine, var.toInt());
        case QVariant::String:
            return QScriptValue(engine, var.toString());
        case QVariant::Time: {
            QDateTime t(QDate::currentDate(), var.toTime());
            return engine->newDate(t);
        }
        case QVariant::UInt:
            return QScriptValue(engine, var.toUInt());
        default:
            if (var.typeName() == QLatin1String("KUrl")) {
                return QScriptValue(engine, var.value<KUrl>().prettyUrl());
            } else if (var.typeName() == QLatin1String("QColor")) {
                return QScriptValue(engine, var.value<QColor>().name());
            } else if (var.typeName() == QLatin1String("QUrl")) {
                return QScriptValue(engine, var.value<QUrl>().toString());
            }
            break;
    }

    return qScriptValueFromValue(engine, var);
}

