/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

import QtQuick 1.1
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents
import org.kde.draganddrop 1.0
import org.kde.qtextracomponents 0.1


PlasmaComponents.Page {
    id: introPage
    objectName: "introPage"
    anchors {
        fill: parent
        topMargin: toolBar.height
    }

    function push(category)
    {
        var page = mainStack.push(Qt.createComponent("Browser.qml"))
        metadataModel.resourceType = category
    }

    Image {
        id: browserFrame
        z: 100
        source: "image://appbackgrounds/standard"
        fillMode: Image.Tile
        anchors.fill: parent

        MobileComponents.IconGrid {
            id: introGrid
            anchors.fill: parent

            model: MetadataModels.MetadataCloudModel {
                cloudCategory: "rdf:type"
                resourceType: "nfo:FileDataObject"
                minimumRating: metadataModel.minimumRating
                allowedCategories: userTypes.userTypes
            }

            delegate: MobileComponents.ResourceDelegate {
                visible: model["label"] != undefined && model["label"] != "nfo:Application"
                className: model["className"] ? model["className"] : ""
                genericClassName: (introGrid.model == metadataModel) ? (model["genericClassName"] ? model["genericClassName"] : "") : "FileDataObject"

                property string label: i18n("%1 (%2)", userTypes.typeNames[model["label"]], model["count"])

                width: introGrid.delegateWidth
                height: introGrid.delegateHeight

                onClicked: push(model["label"])
            }
        }
    }
}

