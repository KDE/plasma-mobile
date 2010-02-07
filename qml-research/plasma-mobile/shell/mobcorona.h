/*
 *   Copyright 2008 Aaron Seigo <aseigo@kde.org>
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

#ifndef MOBCORONA_H
#define MOBCORONA_H

#include <QtGui/QGraphicsScene>

#include <Plasma/Corona>

namespace Plasma
{
    class Applet;
} // namespace Plasma

/**
 * @short A Corona with mobile considerations
 */
class MobCorona : public Plasma::Corona
{
    Q_OBJECT

public:
    MobCorona(QObject * parent);

    /**
     * Loads the default (system wide) layout for this user
     **/
    void loadDefaultLayout();

    Plasma::Containment *findFreeContainment() const;

    virtual int numScreens() const;
    virtual QRect screenGeometry(int id) const;
    virtual QRegion availableScreenRegion(int id) const;

private:
    void init();
    Plasma::Applet *loadDefaultApplet(const QString &pluginName, Plasma::Containment *c);
};

#endif


