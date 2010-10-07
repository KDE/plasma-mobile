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

#include <Plasma/BusyWidget>
#include <Plasma/CheckBox>
#include <Plasma/ComboBox>
#include <Plasma/FlashingLabel>
#include <Plasma/Frame>
#include <Plasma/GroupBox>
#include <Plasma/IconWidget>
#include <Plasma/ItemBackground>
#include <Plasma/Label>
#include <Plasma/LineEdit>
#include <Plasma/Meter>
#include <Plasma/PushButton>
#include <Plasma/RadioButton>
#include <Plasma/ScrollBar>
#include <Plasma/ScrollWidget>
#include <Plasma/Separator>
#include <Plasma/SignalPlotter>
#include <Plasma/Slider>
#include <Plasma/SpinBox>
#include <Plasma/SvgWidget>
#include <Plasma/TextBrowser>
#include <Plasma/TextEdit>
#include <Plasma/ToolButton>
#include <Plasma/TreeView>
#include <Plasma/VideoWidget>
#include <Plasma/WebView>

#include "declarativetabbar.h"


void GraphicsWidgetsBindingsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.graphicswidgets"));
    qmlRegisterType<DeclarativeTabBar>(uri, 0, 1, "TabBar");

    qmlRegisterType<Plasma::BusyWidget>(uri, 0, 1, "BusyWidget");
    qmlRegisterType<Plasma::CheckBox>(uri, 0, 1, "CheckBox");
    qmlRegisterType<Plasma::ComboBox>(uri, 0, 1, "ComboBox");
    qmlRegisterType<Plasma::FlashingLabel>(uri, 0, 1, "FlashingLabel");
    qmlRegisterType<Plasma::Frame>(uri, 0, 1, "Frame");
    qmlRegisterType<Plasma::GroupBox>(uri, 0, 1, "GroupBox");
    qmlRegisterType<Plasma::IconWidget>(uri, 0, 1, "IconWidget");
    qmlRegisterType<Plasma::ItemBackground>(uri, 0, 1, "ItemBackground");
    qmlRegisterType<Plasma::Label>(uri, 0, 1, "Label");
    qmlRegisterType<Plasma::LineEdit>(uri, 0, 1, "LineEdit");
    qmlRegisterType<Plasma::Meter>(uri, 0, 1, "Meter");
    qmlRegisterType<Plasma::PushButton>(uri, 0, 1, "PushButton");
    qmlRegisterType<Plasma::RadioButton>(uri, 0, 1, "RadioButton");
    qmlRegisterType<Plasma::ScrollBar>(uri, 0, 1, "ScrollBar");
    qmlRegisterType<Plasma::ScrollWidget>(uri, 0, 1, "ScrollWidget");
    qmlRegisterType<Plasma::Separator>(uri, 0, 1, "Separator");
    qmlRegisterType<Plasma::SignalPlotter>(uri, 0, 1, "SignalPlotter");
    qmlRegisterType<Plasma::Slider>(uri, 0, 1, "Slider");
    qmlRegisterType<Plasma::SpinBox>(uri, 0, 1, "SpinBox");
    qmlRegisterType<Plasma::SvgWidget>(uri, 0, 1, "SvgWidget");
    qmlRegisterType<Plasma::TextBrowser>(uri, 0, 1, "TextBrowser");
    qmlRegisterType<Plasma::TextEdit>(uri, 0, 1, "TextEdit");
    qmlRegisterType<Plasma::ToolButton>(uri, 0, 1, "ToolButton");
    qmlRegisterType<Plasma::TreeView>(uri, 0, 1, "TreeView");
    qmlRegisterType<Plasma::VideoWidget>(uri, 0, 1, "VideoWidget");
    qmlRegisterType<Plasma::WebView>(uri, 0, 1, "WebView");
}


#include "graphicswidgetsbindingsplugin.moc"

