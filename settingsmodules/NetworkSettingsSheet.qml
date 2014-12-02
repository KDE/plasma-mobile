/*
 * Copyright (C) 2013 Robin Burchell <robin+mer@viroteck.net>
 * Copyright (C) 2012 Jolla Ltd. <dmitry.rozhkov@jollamobile.com>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import QtQuick.Controls 1.2
import MeeGo.Connman 0.2
import "mustache.js" as M

Item {
    id: networkPage
    property variant mustacheView
    property UserAgent userAgent
    property Timer scanTimer


    property var netfields: {}

    function handleInput(key, value) {
        var dict = {};
        var isDoneEnabled = false;
        console.log("Received from TextField " + key + " " + value);
        dict[key] = value;
        networkPage.netfields = dict;
        for (var id in networkPage.netfields) {
            console.log(id + "-> " + networkPage.netfields[id]);
            isDoneEnabled = isDoneEnabled || networkPage.netfields[id].length;
        }
        networkPage.acceptButtonEnabled = isDoneEnabled;
    }

    Connections {
        target: userAgent
        onUserInputCanceled: {
            console.log("qmlsettings: UserAgent cancelled user input request");
            networkPage.reject()
        }
    }

    Button {
        text: "Reject"
        onClicked: {
            userAgent.sendUserReply({});
            scanTimer.running = true;
        }
    }

    Button {
        text: "Accept"
        onClicked: {
            console.log('clicked Done ' + 'x:' + x + ' y:' + y);
            var fields = networkPage.netfields;
            for (var key in fields) {
                console.log(key + " --> " + fields[key]);
            }
            scanTimer.running = true;
            userAgent.sendUserReply(fields);
        }
    }

    Column {
        spacing: 10
        anchors.fill: parent
        Label {
            anchors { left: parent.left; leftMargin: 10 }
            text: "Sign in to secure Wi-Fi network"
        }
        Label {
            id: networkName
            anchors { left: parent.left; leftMargin: 10 }
        }
        Item {
            height: 30
        }
        Item {
            id: dynFields
            width: parent.width
            height: 200
            property string form_tpl: "
                import QtQuick 2.0
                import com.nokia.meego 2.0
                Item {
                    id: form
                    anchors { fill: parent; margins: 10 }
                    Column {
                        spacing: 5
                        anchors { fill: parent }
                        {{#fields}}
                        Text {
                            text: '{{name}}'
                            color: 'white'
                            font.pointSize: 14
                        }
                        TextField {
                            id: {{id}}
                            signal send (string key, string value)
                            anchors { left: parent.left; right: parent.right }
                            placeholderText: 'enter {{name}}'
                            Component.onCompleted: {
                                {{id}}.send.connect(handleInput);
                            }
                            onTextChanged: {
                                console.log('Sending from TextField {{id}}' + {{id}}.text);
                                {{id}}.send('{{name}}', {{id}}.text);
                            }
                        }
                        {{/fields}}
                    }
                }
            "
            Component.onCompleted: {
                console.log(mustacheView)
                console.log(form_tpl)
                // TODO: can we replace mustache with just regular old bindings?
                var output = M.Mustache.render(form_tpl, mustacheView);
                console.log("Creating " + output)
                var form = Qt.createQmlObject(output, dynFields, "dynamicForm1");
                console.log("Created " + form)
            }
        }
    }
}


