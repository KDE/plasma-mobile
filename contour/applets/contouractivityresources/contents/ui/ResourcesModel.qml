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

ListModel {
    id: resourcesModel
    ListElement {
        name: "Contacts"
        elements: [
            ListElement {
                name: "Bill Jones"
                icon: "pics/qtlogo.png"
            },
            ListElement {
                name: "Jane Doe"
                icon: "pics/qtlogo.png"
            },
            ListElement {
                name: "John Smith"
                icon: "pics/qtlogo.png"
            },
            ListElement {
                name: "John Smith"
                icon: "pics/qtlogo.png"
            },
            ListElement {
                name: "Bill Jones"
                icon: "pics/qtlogo.png"
            },
            ListElement {
                name: "Jane Doe"
                icon: "pics/qtlogo.png"
            },
            ListElement {
                name: "John Smith"
                icon: "pics/qtlogo.png"
            },
            ListElement {
                name: "John Smith"
                icon: "pics/qtlogo.png"
            }
        ]
    }
    ListElement {
        name: "Applications"
        elements: [
            ListElement {
                name: "konqueror"
                icon: "konqueror"
            },
            ListElement {
                name: "kmail"
                icon: "kmail"
            }
        ]
    }
    ListElement {
        name: "Files"
        elements: [
            ListElement {
                name: "Book 1"
                icon: "application-epub"
            },
            ListElement {
                name: "Receipt.pdf"
                icon: "application-pdf"
            }
        ]
    }
    ListElement {
        name: "Communication"
        elements: [
            ListElement {
                name: "Hello, how..."
                icon: "view-pim-mail"
            }
        ]
    }
    ListElement {
        name: "URLs"
        elements: [
            ListElement {
                name: "Gmail"
                icon: "kmail"
            },
            ListElement {
                name: "Facebook"
                icon: "facebook"
            },
            ListElement {
                name: "Kde.org"
                icon: "start-here-kde"
            }
        ]
    }
}
