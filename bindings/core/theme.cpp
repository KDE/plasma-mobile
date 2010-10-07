/***************************************************************************
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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

#include "theme_p.h"

#include <plasma/theme.h>

ThemeProxy::ThemeProxy(QObject *parent)
    : QObject(parent)
{
    connect(Plasma::Theme::defaultTheme(), SIGNAL(themeChanged()), this, SIGNAL(themeChanged()));
}

ThemeProxy::~ThemeProxy()
{
}

QColor ThemeProxy::textColor() const
{
    return Plasma::Theme::defaultTheme()->color(Plasma::Theme::TextColor);
}

QColor ThemeProxy::highlightColor() const
{
    return Plasma::Theme::defaultTheme()->color(Plasma::Theme::HighlightColor);
}

QColor ThemeProxy::backgroundColor() const
{
    return Plasma::Theme::defaultTheme()->color(Plasma::Theme::BackgroundColor);
}

QColor ThemeProxy::buttonTextColor() const
{
    return Plasma::Theme::defaultTheme()->color(Plasma::Theme::ButtonTextColor);
}

QColor ThemeProxy::buttonBackgroundColor() const
{
    return Plasma::Theme::defaultTheme()->color(Plasma::Theme::ButtonBackgroundColor);
}

QColor ThemeProxy::linkColor() const
{
    return Plasma::Theme::defaultTheme()->color(Plasma::Theme::LinkColor);
}

QColor ThemeProxy::visitedLinkColor() const
{
    return Plasma::Theme::defaultTheme()->color(Plasma::Theme::VisitedLinkColor);
}

#include "theme_p.moc"

