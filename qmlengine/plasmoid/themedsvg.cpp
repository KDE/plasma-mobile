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

#include "themedsvg.h"

#include <KDebug>

#include "appletinterface.h"

ThemedSvg::ThemedSvg(QObject *parent)
    : Plasma::Svg(parent)
{
}

void ThemedSvg::setThemedImagePath(const QString &path)
{
    setImagePath(findSvg(engine(), path));
}

QString ThemedSvg::findSvg(QScriptEngine *engine, const QString &file)
{
    AppletInterface *interface = AppletInterface::extract(engine);
    if (!interface) {
        return QString();
    }

    QString path = interface->file("images", file + ".svg");
    if (path.isEmpty()) {
        path = interface->file("images", file + ".svgz");

        if (path.isEmpty()) {
            path = Plasma::Theme::defaultTheme()->imagePath(file);
        }
    }

    return path;
}

ThemedFrameSvg::ThemedFrameSvg(QObject *parent)
    : Plasma::FrameSvg(parent)
{
}

void ThemedFrameSvg::setThemedImagePath(const QString &path)
{
    setImagePath(ThemedSvg::findSvg(engine(), path));
}

#include "themedsvg.moc"

