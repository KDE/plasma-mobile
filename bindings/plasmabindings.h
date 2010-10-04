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

#ifndef PLASMA_BINDINGS_H
#define PLASMA_BINDINGS_H

#include <QtDeclarative/qdeclarative.h>
#include <plasma/widgets/lineedit.h>
#include <plasma/widgets/slider.h>
#include <plasma/widgets/spinbox.h>
#include <plasma/widgets/textedit.h>
#include <plasma/widgets/label.h>
#include <plasma/widgets/checkbox.h>
#include <plasma/widgets/pushbutton.h>
#include <plasma/widgets/svgwidget.h>
#include <plasma/widgets/signalplotter.h>
#include <plasma/widgets/frame.h>
#include <plasma/widgets/iconwidget.h>
#include <plasma/widgets/webview.h>
#include <plasma/extender.h>
#include <plasma/extenderitem.h>
#include <plasma/animator.h>
#include <plasma/framesvg.h>

#include "private/declarative/declarativetabbar_p.h"
#include "private/declarative/gridlayout.h"
#include "private/declarative/theme_p.h"
#include "private/declarative/linearlayout.h"
#include "private/declarative/datasource_p.h"
#include "private/declarative/svgitem_p.h"
#include "private/declarative/framesvgitem_p.h"
#include "phone/phone.h"
#include "plasma/service.h"

void PLASMA_EXPORT setupBindings();

QML_DECLARE_TYPE(Plasma::TextEdit)
QML_DECLARE_TYPE(Plasma::LineEdit)
QML_DECLARE_TYPE(Plasma::PushButton)
QML_DECLARE_TYPE(Plasma::Label)
QML_DECLARE_TYPE(Plasma::Frame)
QML_DECLARE_TYPE(Plasma::CheckBox)
QML_DECLARE_TYPE(Plasma::Slider)
QML_DECLARE_TYPE(Plasma::SpinBox)
QML_DECLARE_TYPE(Plasma::IconWidget)
QML_DECLARE_TYPE(Plasma::SvgWidget)
QML_DECLARE_TYPE(Plasma::FrameSvgItem)
QML_DECLARE_TYPE(Plasma::SignalPlotter)
QML_DECLARE_TYPE(Plasma::WebView)
//QML_DECLARE_TYPE(DeclarativeTabBar)
QML_DECLARE_TYPE(Phone)
QML_DECLARE_TYPE(Plasma::SvgItem)
QML_DECLARE_TYPE(Plasma::FrameSvg)

QML_DECLARE_TYPE(Plasma::ExtenderItem)
QML_DECLARE_TYPE(Plasma::Extender)
QML_DECLARE_TYPE(Plasma::Animator)

QML_DECLARE_TYPE(Plasma::DataSource)

QML_DECLARE_TYPE(ThemeProxy)

QML_DECLARE_INTERFACE(QGraphicsLayoutItem)
QML_DECLARE_INTERFACE(QGraphicsLayout)


//Q_DECLARE_METATYPE(KConfigGroup);
Q_DECLARE_METATYPE(Plasma::Service*);

#endif
