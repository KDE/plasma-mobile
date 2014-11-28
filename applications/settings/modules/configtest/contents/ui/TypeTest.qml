// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011-2012 Sebastian Kügler <mart@kde.org>
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

import QtQuick 2.2
import org.kde.active.settings 2.0 as ActiveSettings
import "testhelper.js" as TestHelper

Flickable {
    id: configTestModule
    objectName: "configTestModule"
    interactive: true
    //anchors.fill: parent
    contentWidth: 800; contentHeight: 1000

    ActiveSettings.ConfigGroup {
        id: configGroup
        file: "active-settings-configtestrc"
        group: "fakeValues"
    }

    Text {
        id: configText
        width: parent.width
        clip: true
        anchors { top: parent.top; topMargin: 8;}
        text: "second ..."
    }


    function testAll() {
        var out = "<h3>Tests</h3>\n<p>";

        out += TestHelper.runTest("string", configGroup.readEntry("fakeString").toString(), "Some _fake_ string.");
        out += TestHelper.runTest("bool", configGroup.readEntry("fakeBool"), true);
        out += TestHelper.runTest("bool string comparison", configGroup.readEntry("fakeBool"), "true");
        out += TestHelper.runTest("int", configGroup.readEntry("fakeInt"), 23);
        out += TestHelper.runTest("real", configGroup.readEntry("fakeReal"), 1.87);
        out += TestHelper.runTest("point Qt.point comparison", configGroup.readEntry("fakePoint"), Qt.point(30,40));
        out += TestHelper.runTest("point string comparison", configGroup.readEntry("fakePoint"), "30,40");
        var testDate = new Date(2003, 9, 27, 13, 37, 17);
        print(" These two should be the same date !?! " + Qt.formatDateTime(testDate) + " and " + testDate);
        out += TestHelper.runTest("Date", TestHelper.convertDate(configGroup.readEntry("fakeDateTime")).valueOf(), testDate.valueOf());
        print(" ..." + Qt.formatDateTime(configGroup.readEntry("fakeDateTime")));
        print(" ..." + TestHelper.convertDate(configGroup.readEntry("fakeDateTime")).valueOf());
        print(" ..." + testDate.valueOf());
        out += TestHelper.runTest("StringList", configGroup.readEntry("fakeList") , ["one", "two", "three"]);
        return out + "</p>";
    }

    Component.onCompleted: {
        TestHelper.defaultValues();
        configText.text = testAll();
    }
}
