/*
 *   Copyright 2010 Alexis Menard <menard@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

QGraphicsWidget {
    id: page;

    Component.onCompleted: {
        plasmoid.addEventListener("dataUpdated", dataUpdated)
        dataEngine("time").connectSource("UTC", page, 500)
    }

    function dataUpdated(source, data)
    {
        timeText.text = i18n("Time (fetched without datasource) Is %1 in %2", data.Time.toString(), source)
    }

    Item {
      PlasmaCore.DataSource {
          id: dataSource
          engine: "time"
          connectedSources: ["Local"]
          interval: 500
      }

      resources: [
          Component {
              id: simpleText
              Text {
                  text: modelData + ': ' + dataSource.data['Local'][modelData]
              }
          }
      ]
      Column {
        Text { id: timeText }
        Text { text: 'Time Is ' + dataSource.data['Local']['Time']; }
        Text { text: "Available Data:"; }
        Repeater { model: dataSource.keysForSource('Local'); delegate: simpleText; }
      }
    }
}
