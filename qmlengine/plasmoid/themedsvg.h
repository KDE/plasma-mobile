/*
 *   Copyright 2007-2008,2010 Richard J. Moore <rich@kde.org>
 *   Copyright 2009 Aaron J. Seigo <aseigo@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
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

#ifndef THEMEDSVG_H
#define THEMEDSVG_H

#include <QScriptable>

#include <Plasma/Svg>
#include <Plasma/FrameSvg>

class ThemedSvg : public Plasma::Svg, public QScriptable
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath WRITE setThemedImagePath)

public:
    ThemedSvg(QObject *parent = 0);

    void setThemedImagePath(const QString &path);

    static QString findSvg(QScriptEngine *engine, const QString &file);
};

class ThemedFrameSvg : public Plasma::FrameSvg, public QScriptable
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath WRITE setThemedImagePath)

public:
    ThemedFrameSvg(QObject *parent = 0);

    void setThemedImagePath(const QString &path);
};

#endif

