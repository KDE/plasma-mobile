/***************************************************************************
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>                      *
 *   Copyright 2009 Marco Martin <notmart@gmail.com>                       *
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

class ActivityConfiguration;
class MobView;
class MobCorona;
class MobileWidgetsExplorer;
class MobPluginLoader;

namespace Plasma
{
    class Applet;
    class Containment;
    class Corona;
    class DeclarativeWidget;
} // namespace Plasma

class PlasmaApp : public KUniqueApplication
{
    Q_OBJECT
public:
    PlasmaApp();
    ~PlasmaApp();

    static PlasmaApp* self();
    static bool hasComposite();

    void notifyStartup(bool completed);
    Plasma::Corona* corona();

    QList<Plasma::Containment *> containments() const;
    QList<Plasma::Containment *> panelContainments() const;

protected:
    void setIsDesktop(bool isDesktop);
    void setupHomeScreen();
    void setupContainment(Plasma::Containment *containment);
    void changeContainment(Plasma::Containment *containment);
    void reserveStruts(const int left, const int top, const int right, const int bottom);

public Q_SLOTS:
    void containmentsTransformingChanged(bool transforming);

private Q_SLOTS:
    void cleanup();
    void mainContainmentActivated();
    void manageNewContainment(Plasma::Containment *containment);
    void containmentDestroyed(QObject *);
    void containmentScreenOwnerChanged(int wasScreen, int isScreen, Plasma::Containment *cont);
    void syncConfig();
    void showWidgetsExplorer();
    void showActivityConfiguration(Plasma::Containment *containment);
    void showActivityCreation();
    void mainViewGeometryChanged();

private:
    MobCorona *m_corona;
    MobView *m_mainView;

    //the main declarative scene loader
    Plasma::DeclarativeWidget *m_declarativeWidget;

    QDeclarativeItem *m_homeScreen;

    Plasma::Containment *m_currentContainment;
    QWeakPointer<Plasma::Containment> m_oldContainment;
    QList<Plasma::Containment*> m_alternateContainments;

    QMap<int, Plasma::Containment*> m_containments;
    QHash<int, Plasma::Containment *> m_panelContainments;

    MobPluginLoader *m_pluginLoader;

    QString m_homeScreenPath;
    QWeakPointer<MobileWidgetsExplorer> m_widgetsExplorer;
    QWeakPointer<ActivityConfiguration> m_activityConfiguration;
    bool m_isDesktop;
};

#endif // multiple inclusion guard

