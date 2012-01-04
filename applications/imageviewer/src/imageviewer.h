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


#ifndef IMAGEVIEWER_H
#define IMAGEVIEWER_H

#include "kdeclarativeview.h"
#include <KMainWindow>

class DirModel;

class ImageViewer : public KMainWindow
{
    Q_OBJECT
public:
    ImageViewer(const QString &url);
    virtual ~ImageViewer();
    QString name();
    QIcon icon();
    KConfigGroup config(const QString &group = "Default");

    void setUseGL(const bool on);
    bool useGL() const;

private:
    KDeclarativeView *m_widget;
    DirModel *m_dirModel;
};

#endif // IMAGEVIEWER_H
