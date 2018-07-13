import QtQuick 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.TextField {
    id: root

    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignBottom

    style: TextFieldStyle {
        background: Rectangle {
            opacity: 0
        }
    }

    signal append(string digit)
    onAppend: {
        text += digit
    }
    onTextChanged: {
        text = dialerUtils.formatNumber(text);
    }

    // TODO: search through contacts while typing

    Row {
        anchors {
            right: parent.right
            rightMargin: 6
            verticalCenter: parent.verticalCenter
        }

        PlasmaCore.IconItem {
            id: delBtn
            // ltr confusingly refers to the direction of the arrow in the icon,
            // not the text direction which it should be used in.
            source: LayoutMirroring.enabled ?
                    "edit-clear-locationbar-ltr" : "edit-clear-locationbar-rtl"
            height: Math.max(root.height * 0.8, units.iconSizes.small)
            width: height
            opacity: (root.length > 0 && root.enabled) ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (text.length > 0) {
                        text = text.slice(0, -1);
                    }
                }
            }
        }
    }
}
