import QtQuick 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// TODO: search through contacts while typing
PlasmaComponents.TextField {
    id: root

    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignBottom

    style: TextFieldStyle {
        background: Rectangle {
            opacity: 0
        }
    }

    // append some text to the end of this input
    signal append(string digit)
    onAppend: {
        text += digit
    }
    onTextChanged: {
        text = dialerUtils.formatNumber(text);
    }

    // remove last character from this text input
    signal pop()
    onPop: {
        text = text.slice(0, -1)
    }
}
