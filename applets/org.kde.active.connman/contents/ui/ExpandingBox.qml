/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * LGPL, version 2.1.  The full text of the LGPL Licence is at
 * http://www.gnu.org/licenses/lgpl.html
 */

/*!
  \qmlclass ExpandingBox
  \title ExpandingBox
  \section1 ExpandingBox
  This is a box which can be given any content and adapts its size accordingly.
  The default state of the box only show a header line and an icon which
  indicates if the box is expanded or not. Clicking on the header expands the
  box and shows the content.

  The behaviour isn't final because detailed specifications are missing.

  \section2 API properties
  \qmlproperty bool expanded
  \qmlcm true if the box is currently expanded

  \qmlproperty Row iconRow
  \qmlcm area that can hold a set of icons

  \qmlproperty string titleText
  \qmlcm sets the text shown on the header

  \qmlproperty color titleTextColor
  \qmlcm sets the color of the text shown on the header

  \qmlproperty Component detailsComponent
  \qmlcm contains the content to be shown when the box is expanded

  \qmlproperty Item detailsItem
  \qmlcm stores the contents when created

  \qmlproperty int buttonHeight
  \qmlcm this defines how big the Expanding box is when it's not extended. If you change the orientation and the size, you have to set these too.

  \qmlproperty int buttonWidth
  \qmlcm this defines how big the Expanding box is when it's not extended. If you change the orientation and the size, you have to set these too.

  \qmlproperty Item headerContent
  \qmlcm this Item will appear in the header. It can be used to create complex custom headers.

  \qmlproperty string orientation
  \qmlcm this value defines how ExpandingBox is orientated. Possible values are: "horizontal" - expands to lower; "vertical" - expands to the right. Default is 'horizontal'.
  If you change the orientation and the size during runtime, make sure you change the buttonWidth and buttonHeight too.

  \qmlproperty bool lazyCreation
  \qmlcm this value defines how ExpandingBox is created. By default (false), content to expand is created when the ExpandingBox is first instantiated.  Setting this property to true delays content created if and until the box is expanded.

  \section2 Signals
  \qmlproperty [signal] expandingChanged
  \qmlcm emitted if the box switches between expanded and not expanded
        \param bool expanded
        \qmlpcm indicates if the box is expanded or not \endparam

  \section2 Functions
  \qmlnone

  \section2 Example
  \qml
      ExpandingBox {
          id: expandingBox

          width: 200
          height: 75
          titleText: "ExpandingBox"
          titleTextColor: "black"
          anchors.centerIn:  parent
          detailsComponent: expandingBoxComponent

          Component {
              id: expandingBoxComponent

              Rectangle {
                   id: rect

                   color: "blue"
                   height: 50; width: 150
                   anchors.centerIn: parent

                   Button {
                       text: "Switch"  // switches orientation to vertical
                       onClicked: {
                           expandingBox.width = 75
                           expandingBox.height = 200
                           expandingBox.buttonWidth = 75
                           expandingBox.buttonHeight = 200
                           expandingBox.orientation = "vertical"   // this has to be last, since it triggers the changes
                       }
                   }
              }
          }
      }
  \endqml
*/

import Qt 4.7
import MeeGo.Ux.Kernel 0.1
import MeeGo.Ux.Components.Common 0.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

PlasmaComponents.ListItem {
    id: expandingBox
    enabled: true

    checked: expanded
    onClicked: expanded = !expanded

    property bool expanded: false
    property alias titleText: titleText.text
    property alias titleTextColor: titleText.color
    property Component detailsComponent: null
    property Item detailsItem: null
    property alias iconRow: iconArea.children
    property int buttonHeight: 13
    property int buttonWidth: 13
    property alias headerContent: headerContentArea.children
    property string orientation: "horizontal"
    property bool lazyCreation: false

    signal expandingChanged( bool expanded )

    width: 250
    height: 45// + ( ( titleText.font.pixelSize > expandButton.height ) ? titleText.font.pixelSize : expandButton.height )
    clip: true

    // if new content is set, destroy any old content and create the new one
    onDetailsComponentChanged: {
        if( detailsItem ) {
            detailsItem.destroy()
            detailsItem = null
        }
        if (expanded || !lazyCreation) {
            //console.log("Creating expanding box!") 
            detailsItem = detailsComponent.createObject( boxDetailsArea )
        }
        pulldownImage.componentCompleted  = true
    }

    // if content has been set, destroy any old content and create the new one
    Component.onCompleted: {
        buttonHeight = height
        buttonWidth = width
        pulldownImage.boxReady = true
        if( !lazyCreation && detailsComponent && !pulldownImage.componentCompleted ) {
            if ( detailsItem ) detailsItem.destroy()
            detailsItem = detailsComponent.boxDetailsArea( boxDetailsArea )
        }
    }

    // if the expanded state changes, propagate the change via signal
    onExpandedChanged: {
        if (expanded) {
            if( !detailsItem ) {
                //console.log("Creating expanding box!") 
                detailsItem = detailsComponent.createObject( boxDetailsArea )
            }
        }
        expandingBox.expandingChanged( expanded )
    }

    Item {
        id: pulldownImage

        property bool componentCompleted: false
        property int animationTime: 200
        property bool boxReady: false


        height: expandingBox.height
        width: expandingBox.width


        // the header item contains the title, the image for the button which indicates
        // the expanded state and a GestreuArea to change the expanded state on click
        Item {
            id: header

            // the header adapts its height to the height of the title and the button plus some space
            height: ( expandingBox.orientation == "horizontal" ) ? buttonHeight : parent.height
            width: ( expandingBox.orientation == "horizontal" ) ? parent.width : buttonWidth

            anchors.top:  parent.top

            Row {
                id: iconArea

                anchors { left: parent.left; margins: 5 }
                anchors.verticalCenter: expandButton.verticalCenter
                spacing: anchors.margins
            }

            PlasmaComponents.Label {
                id: titleText

                elide: Text.ElideRight
                anchors.left: iconArea.right
                anchors.right: expandButton.left
                anchors.leftMargin: 10
                anchors.verticalCenter: expandButton.verticalCenter
            }

            Item {
                id: headerContentArea

                x: 5
                y: 5

                width: ( expandingBox.orientation == "horizontal" ) ? expandingBox.width - expandButton.width - 6 * 2 - 10 : parent.width - 10
                height: ( expandingBox.orientation == "horizontal" ) ? parent.height -10 : expandingBox.height - expandButton.height - 6 * 2 - 10

                clip: true
            }

            PlasmaCore.SvgItem {
                id: expandButton


                x: ( expandingBox.orientation == "horizontal" ) ? expandingBox.width - width - 6 :  (header.width - width) / 2
                y: ( expandingBox.orientation == "horizontal" ) ? (header.height - height) / 2 :  expandingBox.height - height - 6

                svg: PlasmaCore.Svg {
                    imagePath: "widgets/arrows"
                }
                width: naturalSize.width
                height: naturalSize.height
                elementId: expandingBox.expanded ? "up-arrow" : "down-arrow"
            }
        }

        // this item is used when creating the content in the detailsItem to set some general properties
        Item {
            id: boxDetailsArea

            property int itemMargins: 3
            opacity: 0

            clip: true
            visible: expandingBox.expanded
            anchors {
                top: ( expandingBox.orientation == "horizontal" ) ? header.bottom : parent.top
                left: ( expandingBox.orientation == "horizontal" ) ? parent.left : header.right
                bottom: parent.bottom
                right: parent.right
                margins: itemMargins
            }
        }
    }

    onOrientationChanged: {
        if(!pulldownImage.boxReady)
            return

        var oldExpanded = expanded
        pulldownImage.animationTime = 0
        expanded = false
        height = buttonHeight
        width = buttonWidth
        expanded = oldExpanded
        pulldownImage.animationTime = 200
    }

    states: [
        State {
            name: "expanded"

            PropertyChanges {
                target: expandingBox
                height: buttonHeight + detailsItem.height + boxDetailsArea.itemMargins * 2
            }

            PropertyChanges {
                target: boxDetailsArea
                visible: true
                opacity: 1.0
            }

            when: { expandingBox.expanded && expandingBox.orientation == "horizontal" }
        },

        State {
            name: "expandedVertical"

            PropertyChanges {
                target: expandingBox
                width: buttonWidth + detailsItem.width + boxDetailsArea.itemMargins * 2
            }

            PropertyChanges {
                target: boxDetailsArea
                visible: true
                opacity: 1.0
            }

            when: { expandingBox.expanded && expandingBox.orientation == "vertical" }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                ParallelAnimation{
                    NumberAnimation {
                        properties: "height"
                        duration: pulldownImage.animationTime
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        properties: "width"
                        duration: pulldownImage.animationTime
                        easing.type: Easing.InCubic
                    }
                }
                NumberAnimation {
                    properties: "opacity"
                    duration: pulldownImage.animationTime
                    easing.type: Easing.OutCubic
                }
            }
        }
    ]
}
