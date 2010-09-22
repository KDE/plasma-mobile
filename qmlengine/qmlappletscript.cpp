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

#include "common/scriptenv.h"
#include "simplebindings/qscriptnonguibookkeeping.cpp"

#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeExpression>
#include <QGraphicsLinearLayout>
#include <QScriptEngine>

#include <KGlobalSettings>
#include <KConfigGroup>
#include <KDebug>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>

K_EXPORT_PLASMA_APPLETSCRIPTENGINE(qmlscripts, QmlAppletScript)

extern void setupBindings();


QmlAppletScript::QmlAppletScript(QObject *parent, const QVariantList &args)
    : Plasma::AppletScript(parent),
      m_engine(0),
      m_env(0)
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

    if (!m_qmlWidget->engine()) {
        return false;
    }

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

    //Glorious hack:steal the engine
    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), "plasmoid.setEngine(this)");
    expr->evaluate();
    delete expr;

    configChanged();

    return true;
}

QString QmlAppletScript::filePath(const QString &type, const QString &file) const
{
    return m_qmlWidget->qmlPath();
}

void QmlAppletScript::configChanged()
{
    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), "configChanged()");
    expr->evaluate();
    delete expr;
}

void QmlAppletScript::constraintsEvent(Plasma::Constraints constraints)
{
    if (constraints & Plasma::FormFactorConstraint) {
        emit formFactorChanged();
    }

    if (constraints & Plasma::LocationConstraint) {
        emit locationChanged();
    }

    if (constraints & Plasma::ContextConstraint) {
        emit contextChanged();
    }
}

void QmlAppletScript::popupEvent(bool popped)
{
    QString expressionString;

    if (popped) {
        expressionString = "popupEvent(true)";
    } else {
        expressionString = "popupEvent(false)";
    }

    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), expressionString);
    expr->evaluate();
    delete expr;
}

void QmlAppletScript::activate()
{
    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), "activate()");
    expr->evaluate();
    delete expr;
}

void QmlAppletScript::setEngine(QScriptEngine *engine)
{
    if (engine == m_engine) {
        return;
    }

    m_engine = engine;
    QScriptValue global = engine->globalObject();

    delete m_env;
    m_env = new ScriptEnv(this, m_engine);
    m_qmlWidget->engine()->rootContext()->setContextProperty("global", m_env);

    registerNonGuiMetaTypes(engine);
}

#include "qmlappletscript.moc"

