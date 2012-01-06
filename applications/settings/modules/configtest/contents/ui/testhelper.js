function runTest(label, condition1, condition2) {
    var rtxt = "";
    if (condition1 == condition2) {
        rtxt += "\n<font color=\"green\"> Success</font> <em>" + label + "</em> : (" + condition1 + ")";
    } else {
        rtxt += "\n<font color=\"red\"> Failed</font> <em>" + label + "</em> :(" + condition1 + " != " + condition2 + ")";
    }
    rtxt += "<br/>";
    return rtxt;
}

function defaultValues() {
    // Fill the example config with default values

    // This serves as example how you can write data in a somewhat type-safe manner
    // into a KConfigGroup

    // String -> QString
    configGroup.writeEntry("fakeString", "Some _fake_ string.");

    // Url -> QUrl (FIXME)
    configGroup.writeEntry("fakeUrl", Url("http://planetkde.org"));

    // bool
    configGroup.writeEntry("fakeBool", true);

    // int
    configGroup.writeEntry("fakeInt", 23);

    // real
    configGroup.writeEntry("fakeReal", 1.87);

    // point, using the QML basic type point
    configGroup.writeEntry("fakePoint", Qt.point(30,40));

    // rect, using the QML basic type rect
    configGroup.writeEntry("fakeRect", Qt.rect(12, 24, 600, 400));

    // Date -> QDateTime
    configGroup.writeEntry("fakeDateTime", new Date(2003, 12, 27, 13, 37, 17));
    print(" == " + new Date(2003, 9, 27, 13, 37, 17).toUTCString());

    // date -> QDateTime
    //configGroup.writeEntry("fakeDate", Qt.date("2003-09-27"));

    // list<Type> -. QVariantList (FIXME)
    configGroup.writeEntry("fakeList", ["one", "two", "three" ]);
}

function convertDate(d) {
    var splitDate = d.toString().split(',');
    print(" out of config: " + d.toString());
    var someday = new Date(splitDate[0], splitDate[1], splitDate[2], splitDate[3], splitDate[4], splitDate[5]);
    print (" ....." + someday.valueOf());
    return someday;
}
