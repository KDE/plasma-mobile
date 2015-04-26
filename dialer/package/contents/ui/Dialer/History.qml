/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQuick.LocalStorage 2.0

Item {

    //TODO: move in root item
    property string providerId: voiceCallmanager.providers.id(0)
    function call(number) {
        if (!voiceCallmanager.activeVoiceCall) {
            console.log("Calling: " + status.text);
            voiceCallmanager.dial(providerId, number);

        } else {
            console.log("Hanging up: " + status.text);
            status.text = '';
            var call = voiceCallmanager.activeVoiceCall;
            if (call) {
                call.hangup();
            }
        }
    }

    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync("PlasmaPhoneDialer", "1.0", "Call history of the Plasma Phone dialer", 1000000);

        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                //callType: wether is incoming, outgoing, unanswered
                tx.executeSql('CREATE TABLE IF NOT EXISTS History(number TEXT, time DATETIME, callType TEXT)');

                // Add (another) greeting row
                //tx.executeSql("INSERT INTO History VALUES(?, datetime('now') )", ['+39000']);

                // Show all added greetings
                var rs = tx.executeSql('SELECT * FROM History');

                var r = ""
                for(var i = 0; i < rs.rows.length; i++) {
                    r += rs.rows.item(i).number + ", " + rs.rows.item(i).time + "\n"
                    historyModel.append({number: rs.rows.item(i).number, time: rs.rows.item(i).time})
                }
            }
        )
    }

    PlasmaComponents.Label {
        anchors.centerIn: parent
        text: i18n("No recent calls")
        visible: false
    }
    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        ListView {
            id: view
            model: ListModel {
                id: historyModel
            }
            delegate: MouseArea {
                width: view.width
                height: childrenRect.height
                onClicked: call(model.number);

                RowLayout {
                    width: view.width
                    PlasmaComponents.Label {
                        text: model.number
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: Qt.formatDateTime(model.time, Qt.locale().dateTimeFormat(Locale.LongFormat));
                    }
                }
            }
        }
    }
}