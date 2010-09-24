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
#include "plasmoid/appletauthorization.h"
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
#include <Plasma/Package>
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
    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), "plasmoid.setEngine(plasmoid)");
    expr->evaluate();
    delete expr;

    return true;
}

QString QmlAppletScript::filePath(const QString &type, const QString &file) const
{
    const QString path = m_env->filePathFromScriptContext(type.toLocal8Bit().constData(), file);

    if (!path.isEmpty()) {
        return path;
    }

    return package()->filePath(type.toLocal8Bit().constData(), file);
}

void QmlAppletScript::configChanged()
{
    if (!m_env) {
        return;
    }

    m_env->callEventListeners("configchanged");
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
    if (!m_env) {
        return;
    }

    QScriptValueList args;
    args << popped;

    m_env->callEventListeners("popupEvent", args);
}

void QmlAppletScript::activate()
{
    if (!m_env) {
        return;
    }

    m_env->callEventListeners("activate");
}

void QmlAppletScript::executeAction(const QString &name)
{
    if (!m_env) {
        return;
    }

    const QString func("action_" + name);
    m_env->callEventListeners(func);
}

bool QmlAppletScript::include(const QString &path)
{
    return m_env->include(path);
}

ScriptEnv *QmlAppletScript::scriptEnv()
{
    return m_env;
}

void QmlAppletScript::setEngine(QScriptValue &val)
{
    if (val.engine() == m_engine) {
        return;
    }

    m_engine = val.engine();
    QScriptValue global = m_engine->globalObject();

    delete m_env;
    m_env = new ScriptEnv(this, m_engine);
    m_env->addMainObjectProperties(val);
    m_qmlWidget->engine()->rootContext()->setContextProperty("global", m_env);

    registerNonGuiMetaTypes(m_engine);

    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), "init()");
    expr->evaluate();
    delete expr;

    AppletAuthorization auth(this);
    if (!m_env->importExtensions(description(), global, auth)) {
        return;
    }

    configChanged();
}

#include "qmlappletscript.moc"

