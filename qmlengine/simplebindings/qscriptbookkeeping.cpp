/*
 *   Copyright 2007-2008 Richard J. Moore <rich@kde.org>
 *   Copyright 2009 Aaron J. Seigo <aseigo@kde.org>
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

#include <QGraphicsWidget>
#include <QScriptEngine>

#include <Plasma/Applet>
#include <Plasma/Animation>
#include <Plasma/Extender>
#include <Plasma/VideoWidget>

#include "variant.h"

//Q_DECLARE_METATYPE(SimpleJavaScriptApplet*)
Q_DECLARE_METATYPE(QGraphicsWidget*)
Q_DECLARE_METATYPE(QGraphicsLayout*)

Q_DECLARE_METATYPE(Plasma::Animation*)
Q_DECLARE_METATYPE(Plasma::Applet*)
Q_DECLARE_METATYPE(Plasma::Extender*)
Q_DECLARE_METATYPE(Plasma::VideoWidget::Controls)
Q_DECLARE_METATYPE(Plasma::Svg*)
Q_DECLARE_METATYPE(Qt::MouseButton)
Q_DECLARE_METATYPE(QList<double>)

QScriptValue qScriptValueFromControls(QScriptEngine *engine, const Plasma::VideoWidget::Controls &controls)
{
    return QScriptValue(engine, controls);
}

void controlsFromScriptValue(const QScriptValue& obj, Plasma::VideoWidget::Controls &controls)
{
    int flagValue = obj.toInteger();
    //FIXME: it has to be a less ugly way to do that :)
    if (flagValue & Plasma::VideoWidget::Play) {
        controls |= Plasma::VideoWidget::Play;
    }
    if (flagValue & Plasma::VideoWidget::Pause) {
        controls |= Plasma::VideoWidget::Pause;
    }
    if (flagValue & Plasma::VideoWidget::Stop) {
        controls |= Plasma::VideoWidget::Stop;
    }
    if (flagValue & Plasma::VideoWidget::PlayPause) {
        controls |= Plasma::VideoWidget::PlayPause;
    }
    if (flagValue & Plasma::VideoWidget::Progress) {
        controls |= Plasma::VideoWidget::Progress;
    }
    if (flagValue & Plasma::VideoWidget::Volume) {
        controls |= Plasma::VideoWidget::Volume;
    }
    if (flagValue & Plasma::VideoWidget::OpenFile) {
        controls |= Plasma::VideoWidget::OpenFile;
    }
}

typedef Plasma::Animation* AnimationPtr;
QScriptValue qScriptValueFromAnimation(QScriptEngine *engine, const AnimationPtr &anim)
{
    return engine->newQObject(const_cast<Plasma::Animation *>(anim), QScriptEngine::AutoOwnership, QScriptEngine::PreferExistingWrapperObject);
}

void abstractAnimationFromQScriptValue(const QScriptValue &scriptValue, AnimationPtr &anim)
{
    QObject *obj = scriptValue.toQObject();
    anim = static_cast<Plasma::Animation *>(obj);
}

typedef QGraphicsWidget * QGraphicsWidgetPtr;
QScriptValue qScriptValueFromQGraphicsWidget(QScriptEngine *engine, const QGraphicsWidgetPtr &anim)
{
    return engine->newQObject(const_cast<QGraphicsWidget *>(anim), QScriptEngine::AutoOwnership, QScriptEngine::PreferExistingWrapperObject);
}

void graphicsWidgetFromQScriptValue(const QScriptValue &scriptValue, QGraphicsWidgetPtr &anim)
{
    QObject *obj = scriptValue.toQObject();
    anim = static_cast<QGraphicsWidget *>(obj);
}

typedef Plasma::Svg * SvgPtr;
QScriptValue qScriptValueFromSvg(QScriptEngine *engine, const SvgPtr &anim)
{
    return engine->newQObject(const_cast<Plasma::Svg *>(anim), QScriptEngine::AutoOwnership, QScriptEngine::PreferExistingWrapperObject);
}

void svgFromQScriptValue(const QScriptValue &scriptValue, SvgPtr &anim)
{
    QObject *obj = scriptValue.toQObject();
    anim = static_cast<Plasma::Svg *>(obj);
}

typedef Plasma::Extender *ExtenderPtr;
QScriptValue qScriptValueFromExtender(QScriptEngine *engine, const ExtenderPtr &extender)
{
    return engine->newQObject(const_cast<Plasma::Extender *>(extender), QScriptEngine::AutoOwnership, QScriptEngine::PreferExistingWrapperObject);
}

void extenderFromQScriptValue(const QScriptValue &scriptValue, ExtenderPtr &extender)
{
    QObject *obj = scriptValue.toQObject();
    extender = static_cast<Plasma::Extender *>(obj);
}

QScriptValue qScriptValueFromMouseButton(QScriptEngine *, const Qt::MouseButton &button)
{
    return int(button);
}

void mouseButtonFromScriptValue(const QScriptValue &scriptValue, Qt::MouseButton &button)
{
    button = static_cast<Qt::MouseButton>(scriptValue.toInt32());
}

using namespace Plasma;

void registerSimpleAppletMetaTypes(QScriptEngine *engine)
{
    qScriptRegisterMetaType<QGraphicsWidget*>(engine, qScriptValueFromQGraphicsWidget, graphicsWidgetFromQScriptValue);
    qScriptRegisterMetaType<Plasma::Svg*>(engine, qScriptValueFromSvg, svgFromQScriptValue);

    qScriptRegisterSequenceMetaType<QList<double> >(engine);
    qScriptRegisterMetaType<Plasma::Animation *>(engine, qScriptValueFromAnimation, abstractAnimationFromQScriptValue);
    qScriptRegisterMetaType<Plasma::Extender *>(engine, qScriptValueFromExtender, extenderFromQScriptValue);
    qScriptRegisterMetaType<Plasma::VideoWidget::Controls>(engine, qScriptValueFromControls, controlsFromScriptValue, QScriptValue());
    qScriptRegisterMetaType<Qt::MouseButton>(engine, qScriptValueFromMouseButton, mouseButtonFromScriptValue);
}

#include "simplebindings/qscriptnonguibookkeeping.cpp"

