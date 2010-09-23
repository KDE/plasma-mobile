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

#ifndef QML_APPLETSCRIPT_H
#define QML_APPLETSCRIPT_H

#include <QScriptValue>

#include <Plasma/AppletScript>

class AppletInterface;

namespace Plasma
{
    class QmlWidget;
}

class ScriptEnv;

class QmlAppletScript : public Plasma::AppletScript
{
Q_OBJECT

public:
    QmlAppletScript(QObject *parent, const QVariantList &args);
    ~QmlAppletScript();

    void setEngine(const QScriptValue &val);

    QString filePath(const QString &type, const QString &file) const;
    void configChanged();

    void executeAction(const QString &name);

    void constraintsEvent(Plasma::Constraints constraints);

public Q_SLOTS:
    void popupEvent(bool popped);
    void activate();

protected:
    bool init();

Q_SIGNALS:
    void formFactorChanged();
    void locationChanged();
    void contextChanged();

private:
    Plasma::QmlWidget *m_qmlWidget;
    AppletInterface *m_interface;
    QScriptEngine *m_engine;
    ScriptEnv *m_env;
};

#endif
