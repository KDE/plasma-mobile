Button {
    property bool defaultAction: true
    onClicked: {
        if (defaultAction){
            typedNumber = typedNumber + text;
        }
    }
}
