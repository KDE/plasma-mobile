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
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.runnermodel 0.1 as RunnerModels


PlasmaComponents.TabBar {
    id: tabBar

    property Component startComponent: topComponent

    anchors {
        top: searchField.bottom
        topMargin: 8
        horizontalCenter: parent.horizontalCenter
    }
    width: Math.min(implicitWidth, parent.width - 100)

    CategoryTab {
        text: i18n("Top")
        component: topComponent
        resourceType: "_top"
    }
    CategoryTab {
        text: i18n("Apps")
        component: appsComponent
        resourceType: "_Apps"
    }
    CategoryTab {
        text: i18n("Bookmarks")
        resourceType: "nfo:Bookmark"
        component: bookmarksComponent
    }
    CategoryTab {
        text: i18n("Contacts")
        resourceType: "nfo:Contact"
        component: contactsComponent
    }
    CategoryTab {
        text: i18n("Documents")
        resourceType: "nfo:Document"
        component: documentsComponent
    }
    CategoryTab {
        text: i18n("Images")
        resourceType: "nfo:Image"
        component: imagesComponent
    }
    CategoryTab {
        text: i18n("Music")
        resourceType: "nfo:Audio"
        component: musicComponent
    }
    CategoryTab {
        text: i18n("Videos")
        resourceType: "nfo:Video"
        component: videoComponent
    }
    CategoryTab {
        text: i18n("Widgets")
        component: widgetsComponent
        resourceType: "_Widgets"
    }

    Component {
        id: topComponent
        ResourceBrowser {
            model: MetadataModels.MetadataModel {
                sortOrder: Qt.DescendingOrder
                activityId: "!"+activitySource.data["Status"]["Current"]
                sortBy: ["nao:numericRating"]
                limit: 20
                queryString: searchField.searchQuery
            }
        }
    }

    Component {
        id: appsComponent
        ResourceBrowser {
            defaultClassName: "FileDataObject"
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
                sortBy: ["nie:title"]
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
