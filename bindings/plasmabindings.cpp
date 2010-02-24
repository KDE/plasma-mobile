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

QML_REGISTER_TYPE(Plasma, 0, 1, Label, Plasma::Label);
QML_REGISTER_TYPE(Plasma, 0, 1, Checkbox, Plasma::CheckBox);
QML_REGISTER_TYPE(Plasma, 0, 1, TextEdit, Plasma::TextEdit);
QML_REGISTER_TYPE(Plasma, 0, 1, LineEdit, Plasma::LineEdit);
QML_REGISTER_TYPE(Plasma, 0, 1, PushButton, Plasma::PushButton);
QML_REGISTER_TYPE(Plasma, 0, 1, Slider, Plasma::Slider);
QML_REGISTER_TYPE(Plasma, 0, 1, SpinBox, Plasma::SpinBox);

QML_REGISTER_TYPE(Plasma, 0, 1, SvgWidget, Plasma::SvgWidget);
QML_REGISTER_TYPE(Plasma, 0, 1, Svg, Plasma::Svg);
QML_REGISTER_TYPE(Plasma, 0, 1, FrameSvg, Plasma::FrameSvg);

//QML_REGISTER_TYPE(Plasma, 0, 1, DataSource, Plasma::DataSource);

}