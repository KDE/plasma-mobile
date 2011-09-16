/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
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


#ifndef VIDEOPLAYER_H
#define VIDEOPLAYER_H

#include "view.h"
//#include <kxmlguiwindow.h>

#include <QResizeEvent>


class VideoPlayer : public KMainWindow
{
    Q_OBJECT
public:
    VideoPlayer(const QString &url);
    virtual ~VideoPlayer();
    QString name();
    QIcon icon();
    KConfigGroup config(const QString &group = "Default");

    void setUseGL(const bool on);
    bool useGL() const;

protected:
    void resizeEvent(QResizeEvent * event);
    void moveEvent(QMoveEvent * event);


private:
    AppView *m_widget;
};

#endif // VIDEOPLAYER_H
