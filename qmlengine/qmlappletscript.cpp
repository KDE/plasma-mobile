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
#include "engineaccess.h"
#include "plasmoid/appletauthorization.h"
#include "plasmoid/themedsvg.h"
#include "../bindings/plasmabindings.h"
#include "../common/qmlwidget.h"

#include "common/scriptenv.h"

#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeExpression>
#include <QGraphicsLinearLayout>
#include <QScriptValueIterator>
#include <QScriptEngine>

#include <KGlobalSettings>
#include <KConfigGroup>
#include <KDebug>

#include <Plasma/Applet>
#include <Plasma/Svg>
#include <Plasma/FrameSvg>
#include <Plasma/Package>
#include <Plasma/PopupApplet>

K_EXPORT_PLASMA_APPLETSCRIPTENGINE(qmlscripts, QmlAppletScript)

extern void setupBindings();

QScriptValue constructKUrlClass(QScriptEngine *engine);
void registerSimpleAppletMetaTypes(QScriptEngine *engine);
void registerNonGuiMetaTypes(QScriptEngine *engine);

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

    m_engineAccess = new EngineAccess(this);
    m_qmlWidget->engine()->rootContext()->setContextProperty("__engineAccess", m_engineAccess);

    //Glorious hack:steal the engine
    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), "__engineAccess.setEngine(this)");
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

QScriptValue QmlAppletScript::newPlasmaSvg(QScriptContext *context, QScriptEngine *engine)
{
    if (context->argumentCount() == 0) {
        return context->throwError(i18n("Constructor takes at least 1 argument"));
    }

    const QString filename = context->argument(0).toString();
    bool parentedToApplet = false;
    QGraphicsWidget *parent = extractParent(context, engine, 1, &parentedToApplet);
    Plasma::Svg *svg = new ThemedSvg(0);
    svg->setImagePath(ThemedSvg::findSvg(engine, filename));

    QScriptValue obj = engine->newQObject(svg);
    ScriptEnv::registerEnums(obj, *svg->metaObject());

    return obj;
}

QScriptValue QmlAppletScript::newPlasmaFrameSvg(QScriptContext *context, QScriptEngine *engine)
{
    if (context->argumentCount() == 0) {
        return context->throwError(i18n("Constructor takes at least 1 argument"));
    }

    QString filename = context->argument(0).toString();

    bool parentedToApplet = false;
    QGraphicsWidget *parent = extractParent(context, engine, 1, &parentedToApplet);
    Plasma::FrameSvg *frameSvg = new ThemedFrameSvg(parent);
    frameSvg->setImagePath(ThemedSvg::findSvg(engine, filename));

    QScriptValue obj = engine->newQObject(frameSvg);
    ScriptEnv::registerEnums(obj, *frameSvg->metaObject());

    return obj;
}

QGraphicsWidget *QmlAppletScript::extractParent(QScriptContext *context, QScriptEngine *engine,
                                                       int argIndex, bool *parentedToApplet)
{
    if (parentedToApplet) {
        *parentedToApplet = false;
    }

    QGraphicsWidget *parent = 0;
    if (context->argumentCount() >= argIndex) {
        parent = qobject_cast<QGraphicsWidget*>(context->argument(argIndex).toQObject());
    }

    if (!parent) {
        AppletInterface *interface = AppletInterface::extract(engine);
        if (!interface) {
            return 0;
        }

        //kDebug() << "got the applet!";
        parent = interface->applet();

        if (parentedToApplet) {
            *parentedToApplet = true;
        }
    }

    return parent;
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

void QmlAppletScript::setupObjects()
{
    QScriptValue global = m_engine->globalObject();

    m_qmlWidget->engine()->rootContext()->setContextProperty("__engineAccess", 0);
    m_engineAccess->deleteLater();

    m_self = m_engine->newQObject(m_interface);
    m_self.setScope(global);
    global.setProperty("plasmoid", m_self);
    m_env->addMainObjectProperties(m_self);

    QScriptValue args = m_engine->newArray();
    int i = 0;
    foreach (const QVariant &arg, applet()->startupArguments()) {
        args.setProperty(i, m_engine->newVariant(arg));
        ++i;
    }
    global.setProperty("startupArguments", args);

    // Add stuff from KDE libs
    qScriptRegisterSequenceMetaType<KUrl::List>(m_engine);
    global.setProperty("Url", constructKUrlClass(m_engine));

    // Add stuff from Plasma
    global.setProperty("Svg", m_engine->newFunction(QmlAppletScript::newPlasmaSvg));
    global.setProperty("FrameSvg", m_engine->newFunction(QmlAppletScript::newPlasmaFrameSvg));
}

void QmlAppletScript::setEngine(QScriptValue &val)
{
    if (val.engine() == m_engine) {
        return;
    }

    m_engine = val.engine();
    connect(m_engine, SIGNAL(signalHandlerException(const QScriptValue &)),
            this, SLOT(signalHandlerException(const QScriptValue &)));
    QScriptValue originalGlobalObject = m_engine->globalObject();

    QScriptValue newGlobalObject = m_engine->newObject();

    QString eval = QLatin1String("eval");
    QString version = QLatin1String("version");

    {
        QScriptValueIterator iter(originalGlobalObject);
        QVector<QString> names;
        QVector<QScriptValue> values;
        QVector<QScriptValue::PropertyFlags> flags;
        while (iter.hasNext()) {
            iter.next();

            QString name = iter.name();

            if (name == version) {
                continue;
            }

            if (name != eval) {
                names.append(name);
                values.append(iter.value());
                flags.append(iter.flags() | QScriptValue::Undeletable);
            }
            newGlobalObject.setProperty(iter.scriptName(), iter.value());

           // m_illegalNames.insert(name);
        }

    }

    m_engine->setGlobalObject(newGlobalObject);

    delete m_env;
    m_env = new ScriptEnv(this, m_engine);
    //m_env->addMainObjectProperties(newGlobalObject);

    setupObjects();

    AppletAuthorization auth(this);
    if (!m_env->importExtensions(description(), m_self, auth)) {
        return;
    }

    qScriptRegisterSequenceMetaType<KUrl::List>(m_engine);
    registerNonGuiMetaTypes(m_engine);
    registerSimpleAppletMetaTypes(m_engine);

    QDeclarativeExpression *expr = new QDeclarativeExpression(m_qmlWidget->engine()->rootContext(), m_qmlWidget->rootObject(), "init()");
    expr->evaluate();
    delete expr;

    configChanged();
}

void QmlAppletScript::signalHandlerException(const QScriptValue &exception)
{
    kWarning()<<"Exception caught: "<<exception.toVariant();
}

#include "qmlappletscript.moc"

