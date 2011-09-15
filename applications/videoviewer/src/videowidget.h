/*
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef VIDEO_WIDGET_H_
#define VIDEO_WIDGET_H_

#include <QFrame>
#include <QString>

/**
 * VideoWidget
 */
class VideoWidget: public QFrame {
    Q_OBJECT

public:
    virtual ~VideoWidget();

    static VideoWidget * self();

public Q_SLOTS:
    void OpenUri(const QString & uri);

    void Pause();
    void Play();
    void Stop();

    QString PlaybackStatus() const;

private:
    VideoWidget();

    class Private;
    Private * const d;
};

#endif // VIDEO_WIDGET_H_
