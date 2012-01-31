/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings
import org.kde.qtextracomponents 0.1

Item {
    id: mainItem
    objectName: "completionPopup"

    signal urlFilterChanged()

    width: 100
    height: 360
    state: "expanded"

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.FrameSvgItem {
        id: frame
        objectName: "frame"

        anchors.fill: parent
        imagePath: "dialogs/background"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        Component {
            id: myDelegate
            Item {
                id: delegateContainer
                height: 64
                width: 380
                anchors.topMargin: 8

                QIconItem {
                    id: previewImage
                    width: 48
                    height: 32
                    icon: QIcon(iconName)
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.rightMargin: 8
                }
                PlasmaComponents.Label {
                    height: 20
                    width: 320
                    id: labelText
                    text: name
                    elide: Text.ElideMiddle
                    anchors.left: previewImage.right
                    anchors.leftMargin: 12
                    anchors.bottom : parent.verticalCenter
                }

                PlasmaComponents.Label {
                    height: 20
                    id: descriptionText
                    text: url
                    opacity: 0.6
                    elide: Text.ElideMiddle
                    anchors.left: previewImage.right
                    anchors.leftMargin: 12
                    width: 320
                    anchors.top: parent.verticalCenter
                }

                QImageItem {
                    id: rightPreview
                    width: 32
                    height: 32
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    image: preview
                }
                MouseArea {
                    anchors.fill: delegateContainer
                    onClicked: {
                        //print("URL from completer chosen: " + name + " " + url);
                        urlEntered(url);
                        mainItem.state = "collapsed";
                    }
                }

            }
        }

        ActiveSettings.SettingsItem {
            id: settingsItem
            initialPage: dashboard
            anchors {
                fill: parent
                leftMargin: frame.margins.left * 2
                rightMargin: frame.margins.right * 2
                topMargin: frame.margins.top * 2
                bottomMargin: frame.margins.bottom * 2
            }
        }

        PlasmaCore.Svg { id: configSvg; imagePath: "widgets/configuration-icons"; }
        PlasmaCore.Svg { id: arrowSvg; imagePath: "widgets/arrows"; }

        MobileComponents.ActionButton {
            svg: configSvg
            width: 48
            height: width
            anchors.top: settingsItem.top
            anchors.right: settingsItem.right
            elementId: "configure"
            onClicked: {
                var webModule = "org.kde.active.settings.web";
                if (settingsItem.module != webModule) {
                    settingsItem.module = webModule;
                    svg = arrowSvg;
                    elementId = "left-arrow";
                } else {
                    settingsItem.module = "";
                    settingsItem.replace(dashboard);
                    svg = configSvg;
                    elementId = "configure";
                }
            }
        }

        PlasmaComponents.Page {
            id: dashboard
            objectName: "dashboard"
            anchors.fill: parent
            QIconItem {
                id: rssButton
                height: 32
                width: height
                visible: {
                    print("Feeds are: " + webView.rssFeeds);
                    return webView.rssFeeds.length != 0
                }
                anchors { top: parent.top; left: parent.left; topMargin: 0; leftMargin: 0; }
                icon: "application-rss+xml"
                MouseArea {
                    anchors.fill: parent
                    onPressed: MobileComponents.ActivateAnimation { targetItem: rssButton }
                    onClicked: SequentialAnimation {
                        ScriptAction { script: {
                                // We use a hidden TextInput to borrow its clipboard handling
                                clipBoardHelper.text = webView.rssFeeds[0];
                                clipBoardHelper.selectAll();
                                clipBoardHelper.copy();
                                disappearTimer.running = true;
                                clipBoardHelper.text = ""
                            }
                        }
                        MobileComponents.AppearAnimation { targetItem: rssActionLabel }
                    }
                }
                TextInput { id: clipBoardHelper; visible: false }
                Timer {
                    id: disappearTimer
                    repeat: false
                    interval: 8000
                    running: false
                    onTriggered:MobileComponents.DisappearAnimation { targetItem: rssActionLabel }
                }
            }
            PlasmaComponents.Label {
                id: rssActionLabel
                width: 400
                text: i18n("Link copied to clipboard")
                visible: false
                anchors { top: rssButton.top; bottom: rssButton.bottom; left: rssButton.right; leftMargin: 8 }
            }

            PlasmaComponents.Label {
                id: topLabel
                height: 48
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.leftMargin: 100
                anchors.rightMargin: 100
                elide: Text.ElideMiddle

                Connections {
                    target: urlInput
                    onUrlFilterChanged: {
                        var newFilter = urlInput.urlFilter;
                        //print(" New Filter: " + newFilter);
                        if (newFilter != "") {
                            topLabel.text = i18n("Search for <em>" + newFilter + "</em>...");
                        } else {
                            topLabel.text = i18n("Start typing...");
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: urlInput.urlEntered(urlInput.url)
                }

            }
            Item {
                id: history
                anchors.left: parent.left
                anchors.right: parent.horizontalCenter
                anchors.top: topLabel.bottom
                anchors.bottom: parent.bottom
                anchors.rightMargin: 12
                PlasmaComponents.Label {
                    id: historyLabel
                    text: i18n("Recently visited")
                    font.pointSize: theme.defaultFont.pointSize+8
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                }
                ListView {
                    id: historyList
                    clip: true
                    anchors.fill: parent
                    anchors.topMargin: historyLabel.height + 8
                    model: historyModel
                    delegate: myDelegate
                    highlight: PlasmaComponents.Highlight {}
                    currentIndex: -1
                }
            }

            Item {
                id: bookmarks
                anchors.top: topLabel.bottom
                anchors.left: parent.horizontalCenter
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 12
                PlasmaComponents.Label {
                    id: bookmarksLabel
                    font.pointSize: theme.defaultFont.pointSize+8
                    text: i18n("Bookmarks")
                }
                ListView {
                    clip: true
                    anchors.fill: parent
                    anchors.topMargin: bookmarksLabel.height + 8
                    currentIndex: -1
                    model: bookmarksModel
                    delegate: myDelegate
                    highlight: PlasmaComponents.Highlight {}
                }
            }
        }
    }

    states: [
        State {
            id: expanded
            name: "expanded";
            PropertyChanges {
                target: mainItem
                opacity: 1.0
                scale: 1.0
            }
        },
        State {
            id: collapsed
            name: "collapsed";
            PropertyChanges {
                target: mainItem
                opacity: 0
                scale: 0.9
            }
        }
    ]

    transitions: [
        Transition {
            from: "collapsed"; to: "expanded"
            MobileComponents.AppearAnimation { targetItem: mainItem }
        },
        Transition {
            from: "expanded"; to: "collapsed"
            MobileComponents.DisappearAnimation { targetItem: mainItem }
        }
    ]
}
