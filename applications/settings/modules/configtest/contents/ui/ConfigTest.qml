// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings

Item {
    id: configTestModule
    objectName: "configTestModule"

    width: 800; height: 500

    PlasmaCore.Theme {
        id: theme
    }

    Column {
        id: titleCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12
        Text {
            color: theme.textColor
            text: "<h3>" + settingsComponent.name + "</h3>"
            opacity: 1
        }
        Text {
            id: descriptionLabel
            color: theme.textColor
            text: settingsComponent.description
            opacity: .4
        }
    }

    ActiveSettings.ConfigGroup {
        id: configGroup
        file: "active-settings-configtestrc"
        group: "fakeValues"
    }

    Text {
        id: configText
        width: parent.width
        clip: true
        anchors { top: titleCol.bottom; topMargin: 8;}
        text: "second ..."
    }

    ListView {
        id: configList
        currentIndex: -1
        height: 200
        width: parent.width
        clip: true
        spacing: 4
        anchors {
            //verticalCenter: parent.verticalCenter
            top: configText.bottom
            topMargin: spacing*2
            bottom: parent.bottom
        }
        model: configGroup.keyList
        delegate: configDelegate

        Rectangle { anchors.fill: configList; color: "white"; opacity: 0.1; }
    }
    Component {
        id: configDelegate
        Item {
            height: 24
            width: configList.width
            Text { text: "<b>" + modelData + "</b>:   "; anchors.right: parent.horizontalCenter }
            Text { text: configGroup.readEntry(modelData, "default value"); anchors.left: parent.horizontalCenter }
        }
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

    function testAll() {
        var out = "<h3>Tests</h3>\n<p>";

        out += runTest("string", configGroup.readEntry("fakeString").toString(), "Some _fake_ string.");
        out += runTest("bool", configGroup.readEntry("fakeBool"), true);
        out += runTest("bool string comparison", configGroup.readEntry("fakeBool"), "true");
        out += runTest("int", configGroup.readEntry("fakeInt"), 23);
        out += runTest("real", configGroup.readEntry("fakeReal"), 1.87);
        out += runTest("point Qt.point comparison", configGroup.readEntry("fakePoint"), Qt.point(30,40));
        out += runTest("point string comparison", configGroup.readEntry("fakePoint"), "30,40");
        var testDate = new Date(2003, 9, 27, 13, 37, 17);
        print(" These two should be the same date !?! " + Qt.formatDateTime(testDate) + " and " + testDate);
        out += runTest("Date", convertDate(configGroup.readEntry("fakeDateTime")).valueOf(), testDate.valueOf());
        print(" ..." + Qt.formatDateTime(configGroup.readEntry("fakeDateTime")));
        print(" ..." + convertDate(configGroup.readEntry("fakeDateTime")).valueOf());
        print(" ..." + testDate.valueOf());
        out += runTest("StringList", configGroup.readEntry("fakeList") , ["one", "two", "three"]);
        return out + "</p>";
    }

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
    Component.onCompleted: {
        print("Web.qml done loading.");
        defaultValues();
        configText.text = testAll() + "\n<h3>Config Model</h3>";
    }
}
