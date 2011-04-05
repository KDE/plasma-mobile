/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

QtObject {

    function model(name)
    {
        switch (name) {
        case "Network":
            return networkModel;
            break;
        case "Grandma's birthday":
            return birthdayModel;
            break;
        case "Managing Photos":
            return photosModel;
            break;
        case "Diploma thesis":
            return thesisModel;
            break;
        default:
        }
    }

    property ListModel birthday: ListModel {
        id: birthdayModel
        ListElement {
            text: "Call grandma Niki"
            description: "Niki called you today at 09am"
            icon: "voicecall"
        }
        ListElement {
            text: "Open orange.pdf"
            description: "You often opened this file recently"
            icon: "application-pdf"
        }
        ListElement {
            text: "Send pictures to grandma"
            description: "There are 15 pictures that show grandma Niki"
            icon: "application-pdf"
        }
    }
}
