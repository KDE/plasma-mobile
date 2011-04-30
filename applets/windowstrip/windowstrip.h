/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#ifndef WINDOWSTRIP_H
#define WINDOWSTRIP_H

#include <Plasma/Applet>
#include <Plasma/DeclarativeWidget>
#include <Plasma/Svg>
#include <QtCore/QTimer>

class QDeclarativeItem;

class WindowStrip : public Plasma::DeclarativeWidget
{
    Q_OBJECT

public:
    WindowStrip(QGraphicsWidget* parent);
    ~WindowStrip();
    void init();

private Q_SLOTS:
    void showThumbnails();
    void hideThumbnails();
    //void lockChanged();
    //void windowsPositionsChanged();
    void scrollChanged();
    void updateFrame();
    void updateWindows();

private:
    QHash<WId, QRect> m_windows;
    QPoint m_windowsOffset;
    WId m_desktop;
    QTime m_time; // for profiling
    QTimer m_frameUpdater; // regularly updates the thumbnail rects during animations
    QTimer m_updateController; // stops the frameUpdater afte a timeout
    QDeclarativeItem *m_windowFlicker;
};

#endif