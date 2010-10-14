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

#ifndef DECLARATIVE_APPLETSCRIPT_H
#define DECLARATIVE_APPLETSCRIPT_H

#include <QScriptValue>
#include <QScriptContext>

#include "abstractjsappletscript.h"
#include <Plasma/DataEngine>

class AppletInterface;

namespace Plasma
{
    class DeclarativeWidget;
    class ExtenderItem;
}

class ScriptEnv;
class EngineAccess;

class DeclarativeAppletScript : public AbstractJsAppletScript
{
Q_OBJECT

public:
    DeclarativeAppletScript(QObject *parent, const QVariantList &args);
    ~DeclarativeAppletScript();

    void setEngine(QScriptValue &val);

    QString filePath(const QString &type, const QString &file) const;

    void executeAction(const QString &name);

    void constraintsEvent(Plasma::Constraints constraints);

    bool include(const QString &path);

    ScriptEnv *scriptEnv();

    QScriptValue variantToScriptValue(QVariant var);

    static QScriptValue newPlasmaSvg(QScriptContext *context, QScriptEngine *engine);
    static QScriptValue newPlasmaFrameSvg(QScriptContext *context, QScriptEngine *engine);
    static QScriptValue newPlasmaExtenderItem(QScriptContext *context, QScriptEngine *engine);
    static QScriptValue dataEngine(QScriptContext *context, QScriptEngine *engine);
    static QScriptValue service(QScriptContext *context, QScriptEngine *engine);

public Q_SLOTS:
    void dataUpdated(const QString &name, const Plasma::DataEngine::Data &data);
    void signalHandlerException(const QScriptValue &exception);
    void popupEvent(bool popped);
    void activate();
    void extenderItemRestored(Plasma::ExtenderItem* item);
    void collectGarbage();
    void configChanged();

protected:
    bool init();
    void setupObjects();
    static QGraphicsWidget *extractParent(QScriptContext *context,
                                          QScriptEngine *engine,
                                          int parentIndex = 0,
                                          bool *parentedToApplet = 0);

Q_SIGNALS:
    void formFactorChanged();
    void locationChanged();
    void contextChanged();

private:
    Plasma::DeclarativeWidget *m_declarativeWidget;
    AppletInterface *m_interface;
    EngineAccess *m_engineAccess;
    QScriptEngine *m_engine;
    QScriptValue m_self;
    ScriptEnv *m_env;
};

#endif
