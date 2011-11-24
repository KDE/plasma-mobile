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

Item {
    anchors.fill: parent
    Flow {
        id: categoriesView
        anchors.centerIn: parent
        width: 140 * 6
        property int orientation: ListView.Horizontal

        CategoryButton {
            component: appsComponent
            text: i18n("Apps")
            resourceType: "_Apps"
            icon: "application-x-executable"
        }

        CategoryButton {
            component: bookmarksComponent
            text: i18n("Bookmarks")
            resourceType: "nfo:Bookmark"
            icon: "emblem-favorite"
        }

        CategoryButton {
            component: contactsComponent
            text: i18n("Contacts")
            resourceType: "nco:Contact"
            icon: "view-pim-contacts"
        }

        CategoryButton {
            component: documentsComponent
            text: i18n("Documents")
            resourceType: "nfo:Document"
            icon: "application-vnd.oasis.opendocument.text"
        }

        CategoryButton {
            component: imagesComponent
            text: i18n("Images")
            resourceType: "nfo:Image"
            icon: "image-x-generic"
        }

        CategoryButton {
            component: musicComponent
            text: i18n("Music")
            resourceType: "nfo:Audio"
            icon: "audio-x-generic"
        }

        CategoryButton {
            component: videoComponent
            text: i18n("Videos")
            resourceType: "nfo:Video"
            icon: "video-x-generic"
        }

        CategoryButton {
            component: widgetsComponent
            text: i18n("Widgets")
            resourceType: "_Widgets"
            icon: "dashboard-show"
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
                    filterRole: "name"
                    filterRegExp: ".*"+searchField.searchQuery+".*"
                }
            }
        }

        Component {
            id: bookmarksComponent
            ResourceBrowser {
                model: PlasmaCore.SortFilterModel {
                    //FIXME: the url doesn't get indexed?
                    sourceModel: MetadataModels.MetadataModel {
                        sortOrder: Qt.AscendingOrder
                        activityId: "!"+activitySource.data["Status"]["Current"]
                        sortBy: ["nie:url"]
                        resourceType: "nfo:Bookmark"
                    }
                    filterRole: "url"
                    filterRegExp: ".*"+searchField.searchQuery+".*"
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
                    queryString: searchField.searchQuery
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
                    queryString: searchField.searchQuery
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
                    queryString: searchField.searchQuery
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
                    queryString: searchField.searchQuery
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
                    queryString: searchField.searchQuery
                }
            }
        }

        Component {
            id: widgetsComponent
            WidgetExplorer {}
        }
    }
}

