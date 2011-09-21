/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2,
 *   or (at your option) any later version.
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

#ifndef BUSYWIDGET_H
#define BUSYWIDGET_H


#include <QHash>
#include <QPixmap>
#include <QWidget>

class BusyWidget;

namespace Plasma
{
    class Svg;
}

class BusyWidget : public QWidget
{
    Q_OBJECT

public:
    BusyWidget(QWidget *parent=0);
    ~BusyWidget();

    void paintEvent(QPaintEvent *e);

protected Q_SLOTS:
    void refreshSpinner();

private:
    Plasma::Svg *m_svg;
    QHash<int, QPixmap> m_frames;
    QTimer *m_rotationTimer;
    qreal m_rotation;
};

#endif // multiple inclusion guard
