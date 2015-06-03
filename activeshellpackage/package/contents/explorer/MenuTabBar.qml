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

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.baloo 0.1 as Baloo

PlasmaComponents.TabBar {
    id: tabBar

    property Component startComponent: appsComponent
    anchors {
        top: saveButton.bottom
        topMargin: 8
        horizontalCenter: parent.horizontalCenter
    }
    width: Math.min(implicitWidth, parent.width - 100)

    MobileComponents.ApplicationListModel {
        id: applicationsModel
    }

    CategoryTab {
        text: i18n("Applications")
        component: appsComponent
    }

    CategoryTab {
        text: i18n("Bookmarks")
        component: bookmarksComponent
    }
    CategoryTab {
        text: i18n("Contacts")
        component: contactsComponent
    }
    CategoryTab {
        text: i18n("Documents")
        component: documentsComponent
    }
    CategoryTab {
        text: i18n("Images")
        component: imagesComponent
    }
    CategoryTab {
        text: i18n("Music")
        component: musicComponent
    }
    CategoryTab {
        text: i18n("Videos")
        component: videoComponent
    }
    CategoryTab {
        text: i18n("Widgets")
        component: widgetsComponent
    }

    Component {
        id: bookmarksComponent
        ResourceBrowser {
            resourceType: "Bookmark"
            model: PlasmaCore.SortFilterModel {
                sourceModel: Baloo.BalooDataModel {
                    query {
                        type: "Bookmark"
                    }
                }
            }
        }
    }

    Component {
        id: contactsComponent
        ResourceBrowser {
            resourceType: "Contact"
            model: PlasmaCore.SortFilterModel {
                sourceModel: Baloo.BalooDataModel {
                    query {
                        type: "Contact"
                    }
                }
            }
        }
    }

    Component {
        id: documentsComponent
        ResourceBrowser {
            resourceType: "Document"
            model: PlasmaCore.SortFilterModel {
                sourceModel: Baloo.BalooDataModel {
                    query {
                        type: "Document"
                    }
                 }
            }
        }
    }

    Component {
        id: imagesComponent
        ResourceBrowser {
            resourceType: "Image"
            model: PlasmaCore.SortFilterModel {
                sourceModel: Baloo.BalooDataModel {
                    query {
                        type: "Image"
                    }
                }
            }
        }
    }

    Component {
        id: musicComponent
        ResourceBrowser {
            resourceType: "Audio"
            model: PlasmaCore.SortFilterModel {
                sourceModel: Baloo.BalooDataModel {
                    query {
                        type: "Audio"
                    }
                }
            }
        }
    }

    Component {
        id: videoComponent
        ResourceBrowser {
            resourceType: "Video"
            model: PlasmaCore.SortFilterModel {
                sourceModel: Baloo.BalooDataModel {
                    query {
                        type: "Video"
                    }
                }
            }
        }
    }

    Component {
        id: widgetsComponent
        CommonBrowser {}
    }

    Component {
        id: appsComponent
        CommonBrowser {
            isApplicationExplorer: true
        }
    }
}
