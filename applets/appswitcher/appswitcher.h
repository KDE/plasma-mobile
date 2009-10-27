/*
 *   Copyright 2009 by Alexis Menard <menard@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2,
 *   or (at your option) any later version.
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

#ifndef APPSWITCHER_APPLET_H
#define APPSWITCHER_APPLET_H

#include <Plasma/Applet>


namespace Plasma
{
    class IconWidget;
}

class AppSwitcher: public Plasma::Applet
{
    Q_OBJECT

public:
    AppSwitcher(QObject *parent, const QVariantList &args);
    ~AppSwitcher();
    void init();

protected slots:
    void toggleAppSwitcher(bool pressed);
    void toggleAppSwitcher();
private:
    Plasma::IconWidget *m_icon;
};

K_EXPORT_PLASMA_APPLET(appswitcher, AppSwitcher)

#endif
