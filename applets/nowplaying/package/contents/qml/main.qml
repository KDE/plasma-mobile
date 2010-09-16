/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
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
import Plasma 0.1 as Plasma
import GraphicsLayouts 4.7


QGraphicsWidget {
    id: page;
    preferredSize: "200x200"
    minimumSize: "200x200"



    Item {
      id:main

      Plasma.DataSource {
          id: dataSource
          engine: "nowplaying"
          source: sources[0]
          interval: 500

          onDataChanged: {
              playPause.icon = "media-playback-start"
          }
      }

      Plasma.Theme {
          id: theme
      }

      Plasma.IconWidget {
          id: playPause
          anchors.fill: parent

          onClicked: {
              data = dataSource.service.operationDescription("stop");
              print(dataSource.service.name());
              for ( var i in data ) {
                  print(i + ' -> ' + data[i] );
              }

              dataSource.service.startOperationCall(dataSource.service.operationDescription("stop"));
              print("stopping");
          }
      }
    }
}
