/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

pragma Singleton

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

/*!
   \qmltype Theme
   \inqmlmodule Material 0.1

   \brief Provides access to standard colors that follow the Material Design specification.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */
QtObject {

    property color textColor: theme.textColor
    property color highlightColor: theme.highlightColor
    property color backgroundColor: theme.backgroundColor
    property color linkColor: theme.linkColor
    property color visitedLinkColor: theme.visitedLinkColor

    property color buttonTextColor: theme.buttonTextColor
    property color buttonBackgroundColor: theme.buttonBackgroundColor
    property color buttonHoverColor: theme.buttonHoverColor
    property color buttonFocusColor: theme.buttonFocusColor

    property color viewTextColor: theme.viewTextColor
    property color viewBackgroundColor: theme.viewBackgroundColor
    property color viewHoverColor: theme.viewHoverColor
    property color viewFocusColor: theme.viewFocusColor

    property color complementaryTextColor: theme.complementaryTextColor
    property color complementaryBackgroundColor: theme.complementaryBackgroundColor
    property color complementaryHoverColor: theme.complementaryHoverColor
    property color complementaryFocusColor: theme.complementaryFocusColor

    property variant defaultFont: theme.defaultFont
}
