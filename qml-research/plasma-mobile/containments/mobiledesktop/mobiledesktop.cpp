/*
*   Copyright 2007 by Aaron Seigo <aseigo@kde.org>
*   Copyright 2008 by Alexis Ménard <darktears31@gmail.com>
*
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

#include "mobiledesktop.h"

#include <KDebug>

using namespace Plasma;

MobileDesktop::MobileDesktop(QObject *parent, const QVariantList &args)
    : Containment(parent, args)
{
    resize(800, 480);
 
    setHasConfigurationInterface(true);
    kDebug() << "!!! loading mobile desktop";

}

MobileDesktop::~MobileDesktop()
{
}

K_EXPORT_PLASMA_APPLET(mobiledesktop, MobileDesktop)

#include "mobiledesktop.moc"
