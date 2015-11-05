/*
*   Copyright (C) 2011 by Marco Martin <mart@kde.org>
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 2, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU Library General Public License for more details
*
*   You should have received a copy of the GNU Library General Public
*   License along with this program; if not, write to the
*   Free Software Foundation, Inc.,
*   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
*/

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore

/**
 * This is a label which uses the plasma theme.
 *
 * The characteristics of the text will be automatically set according to the
 * plasma theme. If you need a more customized text item use the Text component
 * from QtQuick.
 *
 * You can use all elements of the QML Text component, in particular the "text"
 * property to define the label text.
 *
 * @inherit QtQuick.Text
 */
Text {
    id: root

    height: Math.round(Math.max(paintedHeight, theme.mSize(theme.defaultFont).height*1.6))
    verticalAlignment: lineCount > 1 ? Text.AlignTop : Text.AlignVCenter

    activeFocusOnTab: false
    renderType: Text.NativeRendering

    font.capitalization: theme.defaultFont.capitalization
    font.family: theme.defaultFont.family
    font.italic: theme.defaultFont.italic
    font.letterSpacing: theme.defaultFont.letterSpacing
    font.pointSize: theme.defaultFont.pointSize
    font.strikeout: theme.defaultFont.strikeout
    font.underline: theme.defaultFont.underline
    font.weight: theme.defaultFont.weight
    font.wordSpacing: theme.defaultFont.wordSpacing
    color: PlasmaCore.ColorScope.textColor

    opacity: enabled? 1 : 0.6

    Accessible.role: Accessible.StaticText
    Accessible.name: text
}
