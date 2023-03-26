// SPDX-FileCopyrightText: 2023 Plata Hill <plata.hill@kdemail.net>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import org.kde.kwin

Item {
    id: root

    function run(client) {
        // if (client.output === 0) {
            client.setMaximize(true, true);
            client.noBorder = true;
        // } else {
            // client.noBorder = false;
        // }
    }

    Connections {
        target: Workspace

        function onClientAdded(client) {
            if (client.normalWindow) {
                client.interactiveMoveResizeFinished.connect((client) => {
                    root.run(client);
                });
                root.run(client);
            }
        }

        function onScreensChanged() {
            // Windows are moved from the external screen
            // to the internal screen if the external screen
            // is disconnected.
            const clients = Workspace.clients;

            for (var i = 0; i < clients.length; i++) {
                if (clients[i].normalWindow) {
                    root.run(clients[i]);
                }
            }
        }
    }
}
