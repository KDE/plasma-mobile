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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.metadatamodels 0.1 as MetadataModels


Flow {
    id: categoriesView
    anchors {
        left: parent.left
        right: parent.right
    }
    height: resultsContainer.height
    property int orientation: ListView.Horizontal

    CategoryButton {
        component: appsComponent
        text: i18n("Apps")
        icon: "application-x-executable"
    }

    CategoryButton {
        component: bookmarksComponent
        text: i18n("Bookmarks")
        icon: "emblem-favorite"
    }

    CategoryButton {
        component: contactsComponent
        text: i18n("Contacts")
        icon: "view-pim-contacts"
    }

    CategoryButton {
        component: documentsComponent
        text: i18n("Documents")
        icon: "application-vnd.oasis.opendocument.text"
    }

    CategoryButton {
        component: imagesComponent
        text: i18n("Images")
        icon: "image-x-generic"
    }

    CategoryButton {
        component: musicComponent
        text: i18n("Music")
        icon: "audio-x-generic"
    }

    CategoryButton {
        component: videoComponent
        text: i18n("Videos")
        icon: "video-x-generic"
    }

    CategoryButton {
        component: widgetsComponent
        text: i18n("Widgets")
        icon: "dashboard-show"
    }

    PlasmaCore.DataSource {
        id: activitySource
        engine: "org.kde.activities"
        connectedSources: ["Status"]
        interval: 0
    }

    Component {
        id: appsComponent
        ResourceBrowser {
            model: PlasmaCore.SortFilterModel {
                id: appsModel
                sourceModel: PlasmaCore.DataModel {
                    keyRoleFilter: ".*"
                    dataSource: PlasmaCore.DataSource {
                        id: appsSource
                        engine: "org.kde.active.apps"
                        connectedSources: ["Apps"]
                        interval: 0
                    }
                }
                sortRole: "name"
            }
        }
    }

    Component {
        id: bookmarksComponent
        ResourceBrowser {
            model: MetadataModels.MetadataModel {
                sortOrder: Qt.AscendingOrder
                activityId: "!"+activitySource.data["Status"]["Current"]
                sortBy: ["nie:url"]
                resourceType: "nfo:Bookmark"
            }
        }
    }

    Component {
        id: contactsComponent
        ResourceBrowser {
            model: MetadataModels.MetadataModel {
                sortOrder: Qt.AscendingOrder
                activityId: "!"+activitySource.data["Status"]["Current"]
                sortBy: ["nco:fullname"]
                resourceType: "nco:Contact"
            }
        }
    }

    Component {
        id: documentsComponent
        ResourceBrowser {
            model: MetadataModels.MetadataModel {
                sortBy: ["nfo:fileName"]
                activityId: "!"+activitySource.data["Status"]["Current"]
                sortOrder: Qt.AscendingOrder
                resourceType: "nfo:Document"
            }
        }
    }

    Component {
        id: imagesComponent
        ResourceBrowser {
            model: MetadataModels.MetadataModel {
                sortBy: ["nfo:fileName"]
                activityId: "!"+activitySource.data["Status"]["Current"]
                sortOrder: Qt.AscendingOrder
                resourceType: "nfo:Image"
            }
        }
    }

    Component {
        id: musicComponent
        ResourceBrowser {
            model: MetadataModels.MetadataModel {
                sortBy: ["nfo:fileName"]
                activityId: "!"+activitySource.data["Status"]["Current"]
                sortOrder: Qt.AscendingOrder
                resourceType: "nfo:Audio"
            }
        }
    }

    Component {
        id: videoComponent
        ResourceBrowser {
            model: MetadataModels.MetadataModel {
                sortBy: ["nfo:fileName"]
                activityId: "!"+activitySource.data["Status"]["Current"]
                sortOrder: Qt.AscendingOrder
                resourceType: "nfo:Video"
            }
        }
    }

    Component {
        id: widgetsComponent
        WidgetExplorer {}
    }
}
