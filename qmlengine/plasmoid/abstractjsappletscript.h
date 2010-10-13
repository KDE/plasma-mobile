/*
 *   Copyright 2010 Marco Martin <mart@kde.org>

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

#ifndef ABSTRACTJS_APPLETSCRIPT_H
#define ABSTRACTJS_APPLETSCRIPT_H

#include <QScriptValue>

#include <Plasma/AppletScript>

class AbstractJsAppletScript : public Plasma::AppletScript
{
Q_OBJECT

public:
    AbstractJsAppletScript(QObject *parent, const QVariantList &args = QVariantList());
    ~AbstractJsAppletScript();

    virtual bool include(const QString &path) = 0;
    virtual QString filePath(const QString &type, const QString &file) const = 0;
    virtual QScriptValue variantToScriptValue(QVariant var) = 0;
};

#endif
