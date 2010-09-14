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
#include "appletinterface.h"
#include "../bindings/plasmabindings.h"
#include "../common/qmlwidget.h"

#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeExpression>
#include <QGraphicsLinearLayout>

#include <KGlobalSettings>
#include <KConfigGroup>
#include <KDebug>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>

K_EXPORT_PLASMA_APPLETSCRIPTENGINE(qmlscripts, QmlAppletScript)

extern void setupBindings();



QmlAppletScript::QmlAppletScript(QObject *parent, const QVariantList &args)
    : Plasma::AppletScript(parent)
{
    setupBindings();
    Q_UNUSED(args);
}

QmlAppletScript::~QmlAppletScript()
{
}

bool QmlAppletScript::init()
{
    m_qmlWidget = new Plasma::QmlWidget(applet());
    m_qmlWidget->setQmlPath(mainScript());

    Plasma::Applet *a = applet();
    Plasma::PopupApplet *pa = qobject_cast<Plasma::PopupApplet *>(a);

    if (pa) {
        pa->setPopupIcon(a->icon());
        pa->setGraphicsWidget(m_qmlWidget);
    } else {
        QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(a);
        lay->setContentsMargins(0, 0, 0, 0);
        lay->addItem(m_qmlWidget);
    }

    m_interface = pa ? new PopupAppletInterface(this) : new AppletInterface(this);

    m_qmlWidget->engine()->rootContext()->setContextProperty("plasmoid", m_interface);
    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), "init()");
    expr->evaluate();

    return true;
}

QString QmlAppletScript::filePath(const QString &type, const QString &file) const
{
    return m_qmlWidget->qmlPath();
}

#include "qmlappletscript.moc"

