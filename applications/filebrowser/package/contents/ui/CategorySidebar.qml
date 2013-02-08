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
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0


PlasmaComponents.Page {
    anchors.fill: parent

    MobileComponents.Package {
        id: typePackage
    }
    Connections {
        target: metadataModel.queryProvider
        onResourceTypeChanged: {
            typePackage.name = application.browserPackageForType(metadataModel.queryProvider.resourceType)
            browserAddonLoader.source = typePackage.filePath("ui", "BrowserAddon.qml")
        }
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        Flickable {
            id: mainFlickable
            contentWidth: width
            contentHeight: toolsColumn.height
            Column {
                id: toolsColumn
                spacing: 4
                enabled: fileBrowserRoot.model == metadataModel
                opacity: enabled ? 1 : 0.6
                width: mainFlickable.width

                PlasmaExtras.Heading {
                    text: i18n("Rating")
                    anchors {
                        top: parent.top
                        right: parent.right
                        rightMargin: theme.defaultFont.mSize.width
                    }
                }

                MobileComponents.Rating {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        leftMargin: theme.defaultFont.mSize.width
                    }
                    onScoreChanged: metadataModel.minimumRating = score
                }

                Loader {
                    id: typeFilterLoader
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                Loader {
                    id: browserAddonLoader
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                Component.onCompleted: {
                    if (!exclusiveResourceType && exclusiveMimeTypes.length == 0) {
                        typeFilterLoader.source = "TypeFilter.qml"
                    }
                }
            }
        }
    }
}
