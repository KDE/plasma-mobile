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

#include"plasmabindings.h"

void setupBindings() {

qmlRegisterType<Plasma::Label>("Plasma", 0, 1, "Label");
qmlRegisterType<Plasma::CheckBox>("Plasma", 0, 1, "Checkbox");
qmlRegisterType<Plasma::TextEdit>("Plasma", 0, 1, "TextEdit");
qmlRegisterType<Plasma::LineEdit>("Plasma", 0, 1, "LineEdit");
qmlRegisterType<Plasma::PushButton>("Plasma", 0, 1, "PushButton");
qmlRegisterType<Plasma::Frame>("Plasma", 0, 1, "Frame");
qmlRegisterType<Plasma::Slider>("Plasma", 0, 1, "Slider");
qmlRegisterType<Plasma::SpinBox>("Plasma", 0, 1, "SpinBox");

qmlRegisterType<Plasma::SvgWidget>("Plasma", 0, 1, "SvgWidget");
qmlRegisterType<Plasma::Svg>("Plasma", 0, 1, "Svg");
qmlRegisterType<Plasma::FrameSvg>("Plasma", 0, 1, "FrameSvg");

//qmlRegisterType<Plasma::DataSource>("Plasma", 0, 1, "DataSource");

}