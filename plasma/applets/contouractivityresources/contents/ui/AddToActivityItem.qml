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

import QtQuick 1.0


MenuItem {
    id: menuItem
    text: main.browsingActivity?i18n("remove from current activity"):i18n("add to current activity")
    onActivated: {
        var source = contextMenu.source
        print(source)
        var service = metadataSource.serviceForSource(source)
        var operation
        if (main.browsingActivity) {
            operation = service.operationDescription("removeAssociation")
            operation.ResourceUrl = contextMenu.resourceUrl
            operation.ActivityUrl = plasmoid.activityId
        } else {
            operation = service.operationDescription("addAssociation")
            operation.ResourceUrl = contextMenu.resourceUrl
            operation.ActivityUrl = plasmoid.activityId
        }
        service.startOperationCall(operation)
    }
}
