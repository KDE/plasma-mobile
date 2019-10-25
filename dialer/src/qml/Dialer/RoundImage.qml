/*
 * Copyright 2017-2019  Kaidan Developers and Contributors
 * Copyright 2019  Jonah Brüchert <jbb@kaidan.im>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.6
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.6 as Kirigami

Kirigami.Icon {
	id: img
	property bool isRound: true

        layer.enabled: isRound
        layer.effect: OpacityMask {
        maskSource: Item {
            width: img.width
            height: img.height

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(img.width, img.height)
                height: width
                radius: Math.min(width, height)
            }
        }
    }
}
