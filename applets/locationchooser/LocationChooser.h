/*
 *   Copyright (C) 2012 Ivan Cukic <ivan.cukic(at)kde.org>
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

#ifndef LOCATION_CHOOSER_H
#define LOCATION_CHOOSER_H

#include <Plasma/Applet>
#include <Plasma/PopupApplet>

class LocationChooser : public Plasma::PopupApplet
{
    Q_OBJECT
public:
    LocationChooser(QObject * parent, const QVariantList &args);
    ~LocationChooser();

    void init();

public Q_SLOTS:
    void currentLocationChanged(const QString &id, const QString &name);

protected:
    virtual void popupEvent(bool show);

private:
    class Private;
    Private * const d;
};

K_EXPORT_PLASMA_APPLET(locationchooser, LocationChooser)

#endif // LOCATION_CHOOSER_H
