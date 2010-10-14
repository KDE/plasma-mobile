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

#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeExpression>
#include <QGraphicsLinearLayout>
#include <QScriptEngine>
#include <QScriptValueIterator>
#include <QTimer>

#include <KConfigGroup>
#include <KDebug>
#include <KGlobalSettings>

#include <Plasma/Applet>
#include <Plasma/DeclarativeWidget>
#include <Plasma/Extender>
#include <Plasma/ExtenderItem>
#include <Plasma/FrameSvg>
#include <Plasma/Package>
#include <Plasma/PopupApplet>
#include <Plasma/Svg>


#include "plasmoid/declarativeappletscript.h"

#include "engineaccess.h"
#include "plasmoid/appletauthorization.h"
#include "plasmoid/appletinterface.h"
#include "plasmoid/themedsvg.h"

#include "common/scriptenv.h"
#include "simplebindings/bytearrayclass.h"
#include "simplebindings/dataenginereceiver.h"
#include "simplebindings/i18n.h"

K_EXPORT_PLASMA_APPLETSCRIPTENGINE(declarativeappletscript, DeclarativeAppletScript)


QScriptValue constructIconClass(QScriptEngine *engine);
QScriptValue constructKUrlClass(QScriptEngine *engine);
void registerSimpleAppletMetaTypes(QScriptEngine *engine);
void registerNonGuiMetaTypes(QScriptEngine *engine);

DeclarativeAppletScript::DeclarativeAppletScript(QObject *parent, const QVariantList &args)
    : AbstractJsAppletScript(parent, args),
      m_engine(0),
      m_env(0)
{
    Q_UNUSED(args);
}

DeclarativeAppletScript::~DeclarativeAppletScript()
{
}

bool DeclarativeAppletScript::init()
{
    m_declarativeWidget = new Plasma::DeclarativeWidget(applet());
    m_declarativeWidget->setInitializationDelayed(true);
    m_declarativeWidget->setQmlPath(mainScript());

    if (!m_declarativeWidget->engine()) {
        return false;
    }

    Plasma::Applet *a = applet();
    Plasma::PopupApplet *pa = qobject_cast<Plasma::PopupApplet *>(a);

    if (pa) {
        pa->setPopupIcon(a->icon());
        pa->setGraphicsWidget(m_declarativeWidget);
    } else {
        QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(a);
        lay->setContentsMargins(0, 0, 0, 0);
        lay->addItem(m_declarativeWidget);
    }

    m_interface = pa ? new PopupAppletInterface(this) : new AppletInterface(this);

    m_engineAccess = new EngineAccess(this);
    m_declarativeWidget->engine()->rootContext()->setContextProperty("__engineAccess", m_engineAccess);

    connect(applet(), SIGNAL(extenderItemRestored(Plasma::ExtenderItem*)),
            this, SLOT(extenderItemRestored(Plasma::ExtenderItem*)));
    connect(applet(), SIGNAL(activate()),
            this, SLOT(activate()));

    //Glorious hack:steal the engine
    QDeclarativeExpression *expr = new QDeclarativeExpression(m_declarativeWidget->engine()->rootContext(), m_declarativeWidget->rootObject(), "__engineAccess.setEngine(this)");
    expr->evaluate();
    delete expr;

    return true;
}

void DeclarativeAppletScript::collectGarbage()
{
    m_engine->collectGarbage();
}

QString DeclarativeAppletScript::filePath(const QString &type, const QString &file) const
{
    const QString path = m_env->filePathFromScriptContext(type.toLocal8Bit().constData(), file);

    if (!path.isEmpty()) {
        return path;
    }

    return package()->filePath(type.toLocal8Bit().constData(), file);
}

void DeclarativeAppletScript::configChanged()
{
    if (!m_env) {
        return;
    }

    m_env->callEventListeners("configchanged");
}

QScriptValue DeclarativeAppletScript::newPlasmaSvg(QScriptContext *context, QScriptEngine *engine)
{
    if (context->argumentCount() == 0) {
        return context->throwError(i18n("Constructor takes at least 1 argument"));
    }

    const QString filename = context->argument(0).toString();
    Plasma::Svg *svg = new ThemedSvg(0);
    svg->setImagePath(ThemedSvg::findSvg(engine, filename));

    QScriptValue obj = engine->newQObject(svg);
    ScriptEnv::registerEnums(obj, *svg->metaObject());

    return obj;
}

QScriptValue DeclarativeAppletScript::variantToScriptValue(QVariant var)
{
    return m_engine->newVariant(var);
}

QScriptValue DeclarativeAppletScript::newPlasmaFrameSvg(QScriptContext *context, QScriptEngine *engine)
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

QScriptValue DeclarativeAppletScript::newPlasmaExtenderItem(QScriptContext *context, QScriptEngine *engine)
{
    Plasma::Extender *extender = 0;
    if (context->argumentCount() > 0) {
        extender = qobject_cast<Plasma::Extender *>(context->argument(0).toQObject());
    }

    if (!extender) {
        AppletInterface *interface = AppletInterface::extract(engine);
        if (!interface) {
            engine->undefinedValue();
        }

        extender = interface->extender();
    }

    Plasma::ExtenderItem *extenderItem = new Plasma::ExtenderItem(extender);
    QScriptValue fun = engine->newQObject(extenderItem);
    ScriptEnv::registerEnums(fun, *extenderItem->metaObject());
    return fun;
}

QGraphicsWidget *DeclarativeAppletScript::extractParent(QScriptContext *context, QScriptEngine *engine,
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

void DeclarativeAppletScript::constraintsEvent(Plasma::Constraints constraints)
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

void DeclarativeAppletScript::popupEvent(bool popped)
{
    if (!m_env) {
        return;
    }

    QScriptValueList args;
    args << popped;

    m_env->callEventListeners("popupEvent", args);
}

void DeclarativeAppletScript::dataUpdated(const QString &name, const Plasma::DataEngine::Data &data)
{
    QScriptValueList args;
    args << m_engine->toScriptValue(name) << m_engine->toScriptValue(data);

    m_env->callEventListeners("dataUpdated", args);
}

void DeclarativeAppletScript::extenderItemRestored(Plasma::ExtenderItem* item)
{
    if (!m_env) {
        return;
    }

    QScriptValueList args;
    args << m_engine->newQObject(item, QScriptEngine::AutoOwnership, QScriptEngine::PreferExistingWrapperObject);

    m_env->callEventListeners("initExtenderItem", args);
}

void DeclarativeAppletScript::activate()
{
    if (!m_env) {
        return;
    }

    m_env->callEventListeners("activate");
}

void DeclarativeAppletScript::executeAction(const QString &name)
{
    if (!m_env) {
        return;
    }

    const QString func("action_" + name);
    m_env->callEventListeners(func);
}

bool DeclarativeAppletScript::include(const QString &path)
{
    return m_env->include(path);
}

ScriptEnv *DeclarativeAppletScript::scriptEnv()
{
    return m_env;
}

void DeclarativeAppletScript::setupObjects()
{
    QScriptValue global = m_engine->globalObject();

    m_declarativeWidget->engine()->rootContext()->setContextProperty("__engineAccess", 0);
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

    bindI18N(m_engine);
    global.setProperty("dataEngine", m_engine->newFunction(DeclarativeAppletScript::dataEngine));
    global.setProperty("service", m_engine->newFunction(DeclarativeAppletScript::service));

    //Add stuff from Qt
    ByteArrayClass *baClass = new ByteArrayClass(m_engine);
    global.setProperty("ByteArray", baClass->constructor());
    global.setProperty("QIcon", constructIconClass(m_engine));

    // Add stuff from KDE libs
    qScriptRegisterSequenceMetaType<KUrl::List>(m_engine);
    global.setProperty("Url", constructKUrlClass(m_engine));

    // Add stuff from Plasma
    global.setProperty("Svg", m_engine->newFunction(DeclarativeAppletScript::newPlasmaSvg));
    global.setProperty("FrameSvg", m_engine->newFunction(DeclarativeAppletScript::newPlasmaFrameSvg));
    global.setProperty("ExtenderItem", m_engine->newFunction(DeclarativeAppletScript::newPlasmaExtenderItem));
}

QScriptValue DeclarativeAppletScript::dataEngine(QScriptContext *context, QScriptEngine *engine)
{
    if (context->argumentCount() != 1) {
        return context->throwError(i18n("dataEngine() takes one argument"));
    }

    AppletInterface *interface = AppletInterface::extract(engine);
    if (!interface) {
        return context->throwError(i18n("Could not extract the Applet"));
    }

    const QString dataEngineName = context->argument(0).toString();
    Plasma::DataEngine *dataEngine = interface->dataEngine(dataEngineName);
    QScriptValue v = engine->newQObject(dataEngine, QScriptEngine::QtOwnership, QScriptEngine::PreferExistingWrapperObject);
    v.setProperty("connectSource", engine->newFunction(DataEngineReceiver::connectSource));
    v.setProperty("disconnectSource", engine->newFunction(DataEngineReceiver::disconnectSource));
    return v;
}

QScriptValue DeclarativeAppletScript::service(QScriptContext *context, QScriptEngine *engine)
{
    if (context->argumentCount() != 2) {
        return context->throwError(i18n("service() takes two arguments"));
    }

    QString dataEngine = context->argument(0).toString();

    AppletInterface *interface = AppletInterface::extract(engine);
    if (!interface) {
        return context->throwError(i18n("Could not extract the Applet"));
    }

    Plasma::DataEngine *data = interface->dataEngine(dataEngine);
    QString source = context->argument(1).toString();
    Plasma::Service *service = data->serviceForSource(source);
    //kDebug( )<< "lets try to get" << source << "from" << dataEngine;
    return engine->newQObject(service, QScriptEngine::AutoOwnership);
}

void DeclarativeAppletScript::setEngine(QScriptValue &val)
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

    QTimer::singleShot(0, this, SLOT(configChanged()));
}

void DeclarativeAppletScript::signalHandlerException(const QScriptValue &exception)
{
    kWarning()<<"Exception caught: "<<exception.toVariant();
}

#include "declarativeappletscript.moc"

