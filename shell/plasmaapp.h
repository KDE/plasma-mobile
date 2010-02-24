/*
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2,
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

#ifndef PLASMA_APP_H
#define PLASMA_APP_H

#include <QList>
#include <QtDeclarative>

#include <KUniqueApplication>
#include <plasma/plasma.h>

#ifdef Q_WS_X11
#include <X11/Xlib.h>
#include <fixx11h.h>
#endif

class MobView;
class MobCorona;

namespace Plasma
{
    class Containment;
    class Corona;
} // namespace Plasma

class PlasmaApp : public KUniqueApplication
{
    Q_OBJECT
public:
    ~PlasmaApp();

    static PlasmaApp* self();
    static bool hasComposite();

    void notifyStartup(bool completed);
    Plasma::Corona* corona();

    PlasmaApp();

protected:
    void setupHomeScreen();
    void setupContainment(Plasma::Containment *containment);

private Q_SLOTS:
    void cleanup();
    void mainContainmentActivated();
    void manageNewContainment(Plasma::Containment *containment);
    void syncConfig();
    void changeActivity();

private:
    MobCorona *m_corona;
    MobView *m_mainView;

    QDeclarativeEngine *m_engine;
    QDeclarativeContext *m_context;
    QDeclarativeComponent *m_homescreen;

    QDeclarativeItem *m_mainSlot;
    QDeclarativeItem *m_spareSlot;
    QDeclarativeItem *m_panel;

    QHash<int, Plasma::Containment*> containments;
};

#endif // multiple inclusion guard

