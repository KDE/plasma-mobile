/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>
 *   Copyright 2010 by Marco Martin <mart@kde.org>

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

#include "graphicswidgetsbindingsplugin.h"

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

#include "private/declarative/declarativetabbar_p.h"


void GraphicsWidgetsBindingsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.graphicswidgets"));
    qmlRegisterType<Plasma::Label>(uri, 0, 1, "Label");
    qmlRegisterType<Plasma::CheckBox>(uri, 0, 1, "Checkbox");
    qmlRegisterType<Plasma::TextEdit>(uri, 0, 1, "TextEdit");
    qmlRegisterType<Plasma::LineEdit>(uri, 0, 1, "LineEdit");
    qmlRegisterType<Plasma::PushButton>(uri, 0, 1, "PushButton");
    qmlRegisterType<Plasma::Frame>(uri, 0, 1, "Frame");
    qmlRegisterType<Plasma::IconWidget>(uri, 0, 1, "IconWidget");
    qmlRegisterType<Plasma::Slider>(uri, 0, 1, "Slider");
    qmlRegisterType<Plasma::SpinBox>(uri, 0, 1, "SpinBox");
    qmlRegisterType<Plasma::SignalPlotter>(uri, 0, 1, "SignalPlotter");
    qmlRegisterType<Plasma::WebView>(uri, 0, 1, "WebView");
    qmlRegisterType<DeclarativeTabBar>(uri, 0, 1, "TabBar");
}


#include "graphicswidgetsbindingsplugin.moc"

