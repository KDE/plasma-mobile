/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
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

import Qt 4.7

ListModel {
    id: contactsModel
    ListElement {
        name: "John Doe <john@example.com>"
        status: "online"
    }
    ListElement {
        name: "Foo Bar <foo@foobar.com>"
        status: "away"
    }
    ListElement {
        name: "Konqui the dragon <konqui@kde.org.com>"
        status: "offline"
    }
    ListElement {
        name: "Julius Caesar <Jul00@rome.gov>"
        status: "busy"
    }
    ListElement {
        name: "Albert Einstein <alber@relativity.biz>"
        status: "online"
    }
    ListElement {
        name: "Isaac Newton <isaac43@newton.co.uk>"
        status: "offline"
    }
}