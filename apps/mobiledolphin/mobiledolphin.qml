/***************************************************************************
 *   Copyright 2011 by Davide Bettio <davide.bettio@kdemail.net>           *
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets

Rectangle {
    id: mainRect
    color: "black"
    width: 800
    height: 480

    signal fileClicked(string name);

    PlasmaCore.Theme {
        id: theme
    }

    Rectangle {
        width: mainRect.width
        height: 100
        x: 0
        y: 0
        color: "#303030"
        
        Text {
            text: "File Manager"
            color: "white"
            font.pointSize: 24;
            x: 290
        }
        
        Row {
            x: 10
            y: 50
            spacing: 10
            PlasmaWidgets.PushButton {
                text: "Back"
                width: 50
                height: 40
                font.pointSize: 24;
                onClicked: {
                    mainRect.fileClicked("..");
                }
            }
            
            Text {
                id: directoryLabel
                text: directory
                color: "white"
                font.pointSize: 24;
            }
        }
    }

    ListView {
        id: list
        model: myModel
        width: mainRect.width
        height: mainRect.height - 100
        x: 0
        y: 100
        spacing: 5;
        clip: true
        delegate: Component {
            id: delegateItem  
                
            PlasmaCore.FrameSvgItem {
                id: frameSvg
                imagePath: "widgets/frame"
                prefix: "plain"
                width: list.width
                height: 70
                        
                Row {
                    y: 20
                    id : delegateLayout
                    spacing: 5

                    PlasmaWidgets.IconWidget {
                        icon: decoration
                    }

                    Text {
                        color: "white"
                        text: name
                        font.pointSize: 24;
                    }
                }
                
                
                MouseArea {
                    anchors.fill: frameSvg
                    onClicked: {
                        mainRect.fileClicked(name);
                    }
                }
            }
        }
     }
 }
 