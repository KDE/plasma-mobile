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

#ifndef PLASMA_DESKTOP_H
#define PLASMA_DESKTOP_H

#include <Plasma/Containment>

namespace Plasma
{
}

class QDeclarativeEngine;
class QDeclarativeComponent;

class MobileDesktop : public Plasma::Containment
{
    Q_OBJECT

public:
    MobileDesktop(QObject *parent, const QVariantList &args);
    ~MobileDesktop();
    void init();
private:
    void errorPrint();
    void execute(const QString &fileName);
    void finishExecute();
    
    QDeclarativeEngine* engine;
    QDeclarativeComponent* component;

    bool loaded;

};

#endif // PLASMA_DESKTOP_H
