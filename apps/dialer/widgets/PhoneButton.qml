Button {
    width: phonePad.width / 3
    height: phonePad.height / 4
    property bool defaultAction: true
    onClicked: {
        if (defaultAction){
            typedNumber = typedNumber + text;
        }
    }
}
