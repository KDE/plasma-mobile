/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>

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

#include "qmlappletscript.h"
#include "qmlcontext.h"
#include "qmlengine.h"
#include "qml.h"

#include <QGraphicsScene>
#include <QGraphicsItem>
#include <QGraphicsLinearLayout>

#include <KGlobalSettings>
#include <KConfigGroup>
#include <KDebug>

#include <Plasma/Applet>

K_EXPORT_PLASMA_APPLETSCRIPTENGINE(qmlengine, QmlAppletScript)

QmlAppletScript::QmlAppletScript(QObject *parent, const QVariantList &args)
    : Plasma::AppletScript(parent)
{
    Q_UNUSED(args);
}

QmlAppletScript::~QmlAppletScript()
{
}

bool QmlAppletScript::init()
{
    return true;
}

#include "qmlappletscript.moc"

