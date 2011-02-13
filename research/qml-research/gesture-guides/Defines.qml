/*   vim:set foldenable foldmethod=marker:
 *
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0

Item {
/* padding ----------------------------------------{{{ */
    property int padding: 8
    property int smallPadding: 4
    property int bigPadding: 16
/* }}} */


/* rectangle border properties --------------------{{{*/
    property int radius: 4
    property int borderWidth: 2
/* }}} */


/* general UI properties --------------------------{{{ */
    property int captionHeight: 48
/* }}} */


/* backgrounds ------------------------------------{{{*/
    property Gradient textFieldBackground:
    Gradient {
        GradientStop { position: 0.0; color: "#ddd" }
        GradientStop { position: 0.9; color: "#555" }
        GradientStop { position: 0.0; color: "#333" }
    }

    property Gradient captionBackground:
    Gradient {
        GradientStop { position: 0.0; color: "#888" }
        GradientStop { position: 1.0; color: "#555" }
    }

    property Gradient windowBackground:
    Gradient {
        GradientStop { position: 0.0; color: "#111" }
        GradientStop { position: 1.0; color: "#222" }
    }

    property Gradient listItemBackgroundHighlighted:
    Gradient {
        GradientStop { position: 0.0; color: "#689" }
        GradientStop { position: 1.0; color: "#467" }
    }

    property Gradient listItemBackground:
    Gradient {
        GradientStop { position: 0.0; color: "#555" }
        GradientStop { position: 1.0; color: "#333" }
    }

    property Gradient buttonBackgroundNormal:
    Gradient {
        GradientStop { position: 0.0; color: "#adc" }
        GradientStop { position: 1.0; color: "#698" }
    }

    property Gradient buttonBackgroundPressed:
    Gradient {
        GradientStop { position: 0.0; color: "#476" }
        GradientStop { position: 1.0; color: "#698" }
    }

    property Gradient buttonBackgroundDangerNormal:
    Gradient {
        GradientStop { position: 0.0; color: "#dac" }
        GradientStop { position: 1.0; color: "#968" }
    }

    property Gradient buttonBackgroundDangerPressed:
    Gradient {
        GradientStop { position: 0.0; color: "#746" }
        GradientStop { position: 1.0; color: "#968" }
    }

    property Gradient tooltipBackground:
    Gradient {
        GradientStop { position: 0.0; color: "#ddb" }
        GradientStop { position: 1.0; color: "#997" }
    }

    property color buttonBorderColor: "#9cb"

    property color buttonBorderDangerColor: "#c9b"

/* }}} */

}
