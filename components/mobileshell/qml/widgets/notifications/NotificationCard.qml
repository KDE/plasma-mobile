/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * 
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.15
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    
    default property Item contentItem
    
    property bool tapEnabled: false
    
    property bool swipeGestureEnabled: false
    
    property real dragOffset: 0
    
    signal tapped()
    signal dismissRequested()
    signal configureClicked() // TODO implement settings button
    
    onContentItemChanged: {
        contentItem.parent = contentParent;
        contentItem.anchors.fill = contentParent;
        contentItem.anchors.margins = Kirigami.Units.largeSpacing;
        contentParent.children.push(contentItem);
    }
    
    implicitHeight: contentParent.implicitHeight
    
    NumberAnimation on dragOffset {
        id: dragAnim
        duration: PlasmaCore.Units.longDuration
        onFinished: {
            if (to !== 0) {
                root.dismissRequested();
            }
        }
    }
    
    // glow
    RectangularGlow {
        visible: Math.abs(dragOffset) !== root.width
        anchors.topMargin: 1
        anchors.leftMargin: 1
        anchors.fill: mainCard
        cornerRadius: mainCard.radius * 2
        glowRadius: 2
        spread: 0.2
        color: Qt.lighter(PlasmaCore.Theme.backgroundColor, 0.1)
    }

    // shadow
    Rectangle {
        visible: Math.abs(dragOffset) !== root.width
        anchors.fill: mainCard
        anchors.leftMargin: -1
        anchors.rightMargin: -1
        anchors.bottomMargin: -1
        
        color: Qt.darker(PlasmaCore.Theme.backgroundColor, 1.3)
        radius: PlasmaCore.Units.smallSpacing
    }

    // card
    Rectangle {
        id: mainCard
        anchors.left: parent.left
        anchors.leftMargin: root.dragOffset > 0 ? root.dragOffset : 0
        anchors.right: parent.right
        anchors.rightMargin: root.dragOffset < 0 ? -root.dragOffset : 0
        anchors.top: parent.top
        
        color: (root.tapEnabled && mouseArea.pressed) ? Qt.darker(PlasmaCore.Theme.backgroundColor, 1.1) : PlasmaCore.Theme.backgroundColor
        radius: PlasmaCore.Units.smallSpacing 
        implicitHeight: contentParent.implicitHeight
        clip: true
        
        // ensure this is behind the content to not interfere
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                if (root.tapEnabled) {
                    root.tapped()
                }
            }
        }
        
        // content parent
        Item {
            id: contentParent
            anchors.top: parent.top
            anchors.left: root.dragOffset > 0 ? parent.left : undefined
            anchors.right: root.dragOffset < 0 ? parent.right : undefined
            
            width: root.width
            implicitHeight: contentItem.implicitHeight + contentItem.anchors.topMargin + contentItem.anchors.bottomMargin  
        }
    }
    
    DragHandler {
        id: dragHandler
        enabled: root.swipeGestureEnabled
        yAxis.enabled: false
        
        property real startDragOffset: 0
        property real startPosition: 0
        property bool startActive: false
        
        onTranslationChanged: {
            if (startActive) {
                startDragOffset = root.dragOffset;
                startPosition = translation.x;
                startActive = false;
            }
            root.dragOffset = startDragOffset + (translation.x - startPosition);
        }
        
        onActiveChanged: {
            dragAnim.stop();
            startActive = active;
            
            if (!active) { // release event
                let threshold = PlasmaCore.Units.gridUnit * 5; // drag threshold
                if (root.dragOffset > threshold) {
                    dragAnim.to = root.width;
                } else if (root.dragOffset < -threshold) {
                    dragAnim.to = -root.width;
                } else {
                    dragAnim.to = 0;
                }
                dragAnim.restart();
            }
        }
    }
}
