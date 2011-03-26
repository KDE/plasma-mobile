Button {
    width: 118
    height: 95
    property bool defaultAction: true
    onClicked: {
        if (defaultAction){
            typedNumber = typedNumber + text;
        }
    }
}
