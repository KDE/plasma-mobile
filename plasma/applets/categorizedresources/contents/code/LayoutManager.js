/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

.pragma library

var positions = new Array()

var cellSize = new Object()
cellSize.width = 178
cellSize.height = 158

var resultsFlow

var itemsConfig

//bookkeeping for the item groups
var itemGroups = new Object()

function restore()
{
    itemsConfig = new Object()
    var configString = String(plasmoid.readConfig("ItemsGeometries"))

    //array, a cell for encoded item geometry
    var itemsStrings = configString.split(";")
    for (var i=0; i<itemsStrings.length; i++) {
        //[id, encoded geometry]
        var idConfig = itemsStrings[i].split(":")
        if (idConfig.length < 2) {
            continue
        }

        //array [x, y, width, height]
        var rect = idConfig[1].split(",")
        if (rect.length < 4) {
            continue
        }
        var geomObject = new Object()
        geomObject.x = rect[0]
        geomObject.y = rect[1]
        geomObject.width = rect[2]
        geomObject.height = rect[3]
        itemsConfig[idConfig[0]] = geomObject
    }

}

function save()
{
    var configString = String()

    for (id in itemsConfig) {
        var rect = itemsConfig[id]
        configString += id + ":" + rect.x + "," + rect.y + "," + rect.width + "," + rect.height + ";"
    }

    print("saving "+configString)
    plasmoid.writeConfig("ItemsGeometries", configString)
}

function resetPositions()
{
    positions = new Array()
}

//returns the available size at a given position
function availableSpace(x, y, width, height)
{
    var row = Math.round(x/cellSize.width)
    var column = Math.round(y/cellSize.height)
    var rowsWidth = Math.round(width/cellSize.width)
    var columnsHeight = Math.round(height/cellSize.height)

    var availableSize = new Object
    availableSize.width = 0
    availableSize.height = 0

    if (x < 0 || y < 0) {
        return availableSize;
    } else if (positions[row] == undefined) {
        availableSize.width = width
        availableSize.height = height
        return availableSize;
    } else if (!positions[row][column]) {

        for (var w=0; w<rowsWidth; w++) {
            //occupied?
            if (!positions[row+w] || !positions[row+w][column]) {
                availableSize.width = w+1
            } else {
                break;
            }
        }

        for (var h=0; h<columnsHeight; h++) {
            //occupied?
            if (positions[row][column+h]) {
                //print("occupied"+row+" "+column+" "+h+" "+positions[row][column+h]+" "+availableSize.height)
                break;
            } else {
                availableSize.height = h+1
            }
        }
    }

    availableSize.width *= cellSize.width
    availableSize.height *= cellSize.height

    //don't make it overflow
    availableSize.width = Math.min(availableSize.width,
                                   (resultsFlow.width-row*cellSize.width))

    return availableSize
}

function setSpaceAvailable(x, y, width, height, available)
{
    var row = Math.round(x/cellSize.width)
    var column = Math.round(y/cellSize.height)
    var rowsWidth = Math.round(width/cellSize.width)
    var columnsHeight = Math.round(height/cellSize.height)

    for (var i = row; i<row+rowsWidth; ++i) {
        if (!positions[i]) {
            positions[i] = new Array()
        }
        for (var j = column; j<column+columnsHeight; ++j) {
            positions[i][j] = !available
            print("set "+i+" "+j+" "+!available)
        }
    }
}

function normalizeItemPosition(item)
{
    var x = Math.max(0, Math.round(item.x/cellSize.width)*cellSize.width)
    var y = Math.max(0, Math.round(item.y/cellSize.height)*cellSize.height)

    var width = Math.max(cellSize.width, Math.round(item.width/cellSize.width)*cellSize.width)
    var height = Math.max(cellSize.height, Math.round(item.height/cellSize.height)*cellSize.height)

    item.x = x
    item.y = y
    /*item.width = width
    item.height = height*/
}

function positionItem(item)
{
    var x = Math.max(0, Math.round(item.x/cellSize.width)*cellSize.width)
    var y = Math.max(0, Math.round(item.y/cellSize.height)*cellSize.height)

    var forwardX = x
    var forwardY = y
    var backX = x - cellSize.width
    var backY = y
    var avail
    while (1) {
        //look forward
        var forwardAvail = availableSpace(forwardX, forwardY, item.width, item.height)
        print("checking forward "+forwardX/cellSize.width+" "+forwardY/cellSize.height+" "+forwardAvail.width/cellSize.width+" "+forwardAvail.height/cellSize.height)

        if (forwardAvail.width > 0 && forwardAvail.height > 0) {
            x = forwardX
            y = forwardY
            avail = forwardAvail
            break
        }
        forwardX += cellSize.width
        if (forwardX+item.width > resultsFlow.width) {
            forwardX = 0
            forwardY += cellSize.height
            //forward positions exausted
            if (forwardY > resultsFlow.height) {
                break;
            }
        }

        //backwards positions exausted
        if (backY < 0) {
            continue
        }

        //look backwards
        var backAvail = availableSpace(backX, backY, item.width, item.height)
        print("checking backwards "+backX/cellSize.width+" "+backY/cellSize.height+" "+backAvail.width/cellSize.width+" "+backAvail.height/cellSize.height)

        if (backAvail.width > 0 && backAvail.height > 0) {
            x = backX
            y = backY
            avail = backAvail
            break
        }
        backX -= cellSize.width
        if (backX < 0) {
            backX = resultsFlow.width - item.width
            backY -= cellSize.height
        }
    }
    var width = Math.max(cellSize.width, Math.round(avail.width/cellSize.width)*cellSize.width)
    var height = Math.max(cellSize.height, Math.round(avail.height/cellSize.height)*cellSize.height)

    setSpaceAvailable(x, y, width, height, false)
    item.x = x
    item.y = y

    item.width = width
    item.height = height

    var rect = new Object()
    rect.x = item.x
    rect.y = item.y
    rect.width = item.width
    rect.height = item.height
    itemsConfig[item.category] = rect
    save()
}

