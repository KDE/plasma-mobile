// SPDX-FileCopyrightText: 2023 Plata Hill <plata.hill@kdemail.net>
// SPDX-License-Identifier: LGPL-2.1-or-later

function run(client) {
  if (client.screen === 0) {
    client.setMaximize(true, true);
    client.noBorder = true;
  } else {
    client.noBorder = false;
  }
}

workspace.clientAdded.connect((client) => {
  if (client.normalWindow) {
    client.interactiveMoveResizeFinished.connect((client) => {
      run(client);
    });
    run(client);
  }
});

// Windows are moved from the external screen
// to the internal screen if the external screen
// is disconnected.
workspace.screensChanged.connect(() => {
  const clients = workspace.clientList();

  for (var i = 0; i < clients.length; i++) {
    if (clients[i].normalWindow) {
      run(clients[i]);
    }
  }
});
