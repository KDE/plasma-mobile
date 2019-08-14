import QtQuick 2.0
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1

// TODO: search through contacts while typing
Controls.TextField {
    id: root

    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignBottom

    background: Rectangle {
        opacity: 0
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
