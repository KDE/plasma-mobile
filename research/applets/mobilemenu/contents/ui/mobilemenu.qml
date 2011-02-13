/*
 *   Author: Marco Martin <mart@kde.org>
 *   Date: Sun Feb 6 2011, 12:52:47
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

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.qtextracomponents 4.7

Rectangle {
    width: 240; height: 500
    color: "black"

    ListModel {
        id: suggestionModel
        ListElement {
            elements: [
                ListElement {
                    name: "Bill Jones"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Jane Doe"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "John Smith"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Jack Frost"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Carl Boh"
                    icon: "pics/qtlogo.png"
                }
            ]
        }
        ListElement {
            elements: [
                ListElement {
                    name: "konqueror"
                    icon: "konqueror"
                },
                ListElement {
                    name: "konsole"
                    icon: "konsole"
                },
                ListElement {
                    name: "kmail"
                    icon: "kmail"
                },
                ListElement {
                    name: "akregator"
                    icon: "akregator"
                },
                ListElement {
                    name: "dolphin"
                    icon: "dolphin"
                }
            ]
        }
        ListElement {
            elements: [
                ListElement {
                    name: "Book 1"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Receipt.pdf"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "essay.doc"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Birthday.jpg"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "5th symphony.mp3"
                    icon: "pics/qtlogo.png"
                }
            ]
        }
        ListElement {
            elements: [
                ListElement {
                    name: "Book 1"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Receipt.pdf"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "essay.doc"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Birthday.jpg"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "5th symphony.mp3"
                    icon: "pics/qtlogo.png"
                }
            ]
        }
        ListElement {
            elements: [
                ListElement {
                    name: "Book 1"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Receipt.pdf"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "essay.doc"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "Birthday.jpg"
                    icon: "pics/qtlogo.png"
                },
                ListElement {
                    name: "5th symphony.mp3"
                    icon: "pics/qtlogo.png"
                }
            ]
        }
    }

    PlasmaCore.Svg{
        id: iconsSvg
        imagePath: plasmoid.file("images", "icons.svgz")
    }


     PathView {
         id: mainView
         anchors.fill: parent
         model: suggestionModel

         property int activityRootX: 64
         property int activityRootY: 64

         delegate: Item {
                id: delegate
                width: itemsRow.childrenRect.width
                height: itemsRow.childrenRect.height
                scale: PathView.delegateScale
                opacity: PathView.delegateOpacity

                Rectangle {
                    color: "white"
                    width: itemsRow.width -64
                    height: 12
                    x: 0//-12 * Math.sin(connectorAngle)
                    y: parent.height/2 // + (12 * Math.cos(connectorAngle) -12)
                }

                Row {
                    id: itemsRow
                    Repeater {
                        model: elements

                        Column {
                            x: 0
                            id: wrapper
                            width:100
                            PlasmaCore.SvgItem {
                                width: 128
                                height: 128
                                svg: iconsSvg
                                elementId: "icon-background"

                                QIconItem {
                                    id: elementIcon
                                    anchors.verticalCenter: parent.verticalCenter
                                    width:48
                                    height:48
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    icon: QIcon(model.icon)
                                }
                            }
                            Text {
                                id: nameText
                                text: name
                                font.pointSize: 14
                                wrapMode: Text.WordWrap
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                color: "white"
                            }
                        }
                    }
                    PlasmaCore.SvgItem {
                        width: 128
                        height: 128
                        svg: iconsSvg
                        elementId: "add"
                    }
                }
                Connector {
                    id: itemConnector
                    itemA: activityRootSvg
                    itemB: delegate
                }

               MouseArea {
                      anchors.fill: parent
                      onClicked: {
                          print(itemsRow.childrenRect.width)
                      }
                  }
         }
         clip:true
         offset: 2
         path: Path {
             startX: mainView.width/2; startY: -100
             /*PathAttribute { name: "delegateScale"; value: 1.0 }
             PathAttribute { name: "delegateOpacity"; value: 1.0 }*/
             PathQuad {
                 x: 0
                 y: mainView.height+100
                 controlX: mainView.width
                 controlY: mainView.height/2
            }
         /*   //PathAttribute { name: "delegateScale"; value: 0.3 }
            //PathAttribute { name: "delegateOpacity"; value: 0.0 }
            PathQuad {
                 x: mainView.width/2
                 y: 0
                 controlX: mainView.width/2 -30
                 controlY: 0
            }
           // PathAttribute { name: "delegateOpacity"; value: 0.0 }
            PathQuad {
                 x: mainView.width/2
                 y: mainView.height/2
                 controlX: mainView.width/2 -30
                 controlY: mainView.height/2-30
            }*/
         }
     }
     PlasmaCore.SvgItem {
        id: activityRootSvg
        y:200
        width: 128
        height: 128
        svg: iconsSvg
        elementId: "activity-root"
    }
 }
