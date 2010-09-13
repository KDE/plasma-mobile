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
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: page;
    Item {
      Plasma.DataSource { id: dataSource; engine: "time"; source: "Local"; interval: 500; }
      resources: [
          Component {
              id: simpleText
              Text {
                  text: modelData + ': ' + dataSource.data[modelData]
              }
          }
      ]
      Column {
        Text { text: 'Time Is ' + dataSource.data['time']; }
        Text { text: "Available Data:"; }
        Repeater { model: dataSource.keys; delegate: simpleText; }
      }
    }
}
