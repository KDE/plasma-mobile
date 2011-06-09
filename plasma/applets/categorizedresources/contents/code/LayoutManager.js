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


function isSpaceAvailable(x, y, width, height)
{
    if (positions[x] == undefined || !positions[x][y]) {
        return true
    } else {
        return false
    }
}

function setSpaceAvailable(x, y, width, height, available)
{
    for (var i = x; i<x+width; i += cellSize.width) {
        if (!positions[i]) {
            positions[i] = new Array()
        }
        for (var j = y; j<y+height; j += cellSize.height) {
            positions[i][j] = !available
            print(i+" "+j+" "+!available)
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

    while (1) {
        print("checking"+x+" "+y+" "+isSpaceAvailable(x,y, item.width, item.height))
        if (isSpaceAvailable(x,y, item.width, item.height)) {
            break
        }
        x += cellSize.width
        if (x+item.width > resultsFlow.width) {
            x = 0
            y += cellSize.height
            if (y > resultsFlow.height) {
                break;
            }
        }
    }
    setSpaceAvailable(x, y, item.width, item.height, false)
    item.x = x
    item.y = y

    var width = Math.max(cellSize.width, Math.round(item.width/cellSize.width)*cellSize.width)
    var height = Math.max(cellSize.height, Math.round(item.height/cellSize.height)*cellSize.height)
    item.width = width
    item.height = height
}

