/*
 * Copyright 2008  Petri Damsten <damu@iki.fi>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef WALLPAPER_PREVIEW_HEADER
#define WALLPAPER_PREVIEW_HEADER

#include <QWidget>

#include "plasmagenericshell_export.h"

namespace Plasma{
    class Wallpaper;
    class Svg;
}

class PLASMAGENERICSHELL_EXPORT WallpaperPreview : public QWidget
{
    Q_OBJECT
public:
    WallpaperPreview(QWidget *parent = 0);
    virtual ~WallpaperPreview();

    void setWallpaper(Plasma::Wallpaper* wallpaper);

protected:
    virtual void paintEvent(QPaintEvent* event);
    virtual void resizeEvent(QResizeEvent* event);

protected slots:
    void updateRect(const QRectF& rect);

private:
    Plasma::Wallpaper* m_wallpaper;
    Plasma::Svg* m_wallpaperOverlay;
};

#endif // WALLPAPER_PREVIEW
