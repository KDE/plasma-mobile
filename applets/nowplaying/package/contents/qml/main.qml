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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts


QGraphicsWidget {
    id: page;
    preferredSize: "200x200"
    minimumSize: "200x20"

    Item {
        id:main

        PlasmaCore.DataSource {
            id: dataSource
            engine: "nowplaying"
            source: allSources[0]
            interval: 500

            onDataChanged: {
                if (data.state == "playing") {
                    playPause.setIcon("media-playback-pause")
                } else {
                    playPause.setIcon("media-playback-start")
                }

                progress.value = 100*data.position/data.length
            }
        }

        PlasmaCore.Theme {
                id: theme
        }
    }

    Component.onCompleted:
    {
        dataSource.service.associateWidget(stop, "stop");
        dataSource.service.associateWidget(progress, "progress");
    }

    layout: GraphicsLayouts.QGraphicsLinearLayout {

        PlasmaWidgets.IconWidget {
            id: playPause
            property string state: "stop"

            onClicked: {
                var operation;
                if (dataSource.data.state == "playing") {
                    operation = "pause"
                } else {
                    operation = "play"
                }
                var data = dataSource.service.operationDescription(operation);
                print(dataSource.service.name);

                for ( var i in data ) {
                    print(i + ' -> ' + data[i] );
                }

                dataSource.service.startOperationCall(dataSource.service.operationDescription(operation));
                print("stopping");
            }
        }

        PlasmaWidgets.IconWidget {
            id: stop
            Component.onCompleted: {
                setIcon("media-playback-stop");
            }
            onClicked: {
                var data = dataSource.service.operationDescription("stop");
                print(dataSource.service.name);

                for ( var i in data ) {
                    print(i + ' -> ' + data[i] );
                }

                dataSource.service.startOperationCall(dataSource.service.operationDescription("stop"));
                print("stopping");
            }
        }

        PlasmaWidgets.Slider {
            id: progress
            orientation: Qt.Horizontal

            onSliderMoved: {
                var operation = dataSource.service.operationDescription("seek");
                //FIXME: the line below can't be used because we can't use kconfiggroup
                print(operation.seconds);
                operation.seconds = Math.round(dataSource.data.length*(value/100));

                for ( var i in operation ) {
                    print(i + ' -> ' + operation[i] );
                }

                dataSource.service.startOperationCall(operation);
                print("set progress to " + progress);
            }
        }
    }
}
