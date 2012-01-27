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

#include <KStartupInfoData>
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
class PanelShadows;
class BusyWidget;
class KStartupInfo;

namespace Plasma
{
    class Applet;
    class Containment;
    class Corona;
    class DeclarativeWidget;
} // namespace Plasma

class ContainmentProperties : public QObject
{
    Q_OBJECT
    Q_ENUMS(Location)
    Q_ENUMS(FormFactor)
public:
   /**
    * The Location enumeration describes where on screen an element, such as an
    * Applet or its managing container, is positioned on the screen.
    **/
    enum Location {
        Floating = 0, /**< Free floating. Neither geometry or z-ordering
                        is described precisely by this value. */
        Desktop,      /**< On the planar desktop layer, extending across
                        the full screen from edge to edge */
        FullScreen,   /**< Full screen */
        TopEdge,      /**< Along the top of the screen*/
        BottomEdge,   /**< Along the bottom of the screen*/
        LeftEdge,     /**< Along the left side of the screen */
        RightEdge     /**< Along the right side of the screen */
    };

   /**
    * The FormFactor enumeration describes how a Plasma::Applet should arrange
    * itself. The value is derived from the container managing the Applet
    * (e.g. in Plasma, a Corona on the desktop or on a panel).
    **/
    enum FormFactor {
        Planar = 0,  /**< The applet lives in a plane and has two
                        degrees of freedom to grow. Optimize for
                        desktop, laptop or tablet usage: a high
                        resolution screen 1-3 feet distant from the
                        viewer. */
        MediaCenter, /**< As with Planar, the applet lives in a plane
                        but the interface should be optimized for
                        medium-to-high resolution screens that are
                        5-15 feet distant from the viewer. Sometimes
                        referred to as a "ten foot interface".*/
        Horizontal,  /**< The applet is constrained vertically, but
                        can expand horizontally. */
        Vertical     /**< The applet is constrained horizontally, but
                        can expand vertically. */
    };
private:
    ContainmentProperties(QObject *parent = 0)
      : QObject(parent)
    {}
};

class PlasmaApp : public KUniqueApplication
{
    Q_OBJECT
public:
    PlasmaApp();
    ~PlasmaApp();

    static PlasmaApp* self();
    static QSize defaultScreenSize();

    void notifyStartup(bool completed);
    Plasma::Corona* corona();

    QList<Plasma::Containment *> containments() const;
    QList<Plasma::Containment *> panelContainments() const;

    PanelShadows *panelShadows();

protected:
    void setIsDesktop(bool isDesktop);
    void setupHomeScreen();
    void setupContainment(Plasma::Containment *containment);
    void changeContainment(Plasma::Containment *containment);
    void reserveStruts(const int left, const int top, const int right, const int bottom);

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
    void containmentWallpaperChanged(Plasma::Containment *containment);
    void gotStartup(const KStartupInfoId& id, const KStartupInfoData& data);
    void killStartup(const KStartupInfoId& id);
    void focusMainView();

private:
    MobCorona *m_corona;
    MobView *m_mainView;

    //the main declarative scene loader
    Plasma::DeclarativeWidget *m_declarativeWidget;

    QDeclarativeItem *m_homeScreen;

    Plasma::Containment *m_currentContainment;
    QWeakPointer<Plasma::Containment> m_oldContainment;

    QMap<int, Plasma::Containment*> m_containments;
    QHash<int, Plasma::Containment *> m_panelContainments;

    MobPluginLoader *m_pluginLoader;
    PanelShadows *m_panelShadows;

    QString m_homeScreenPath;
    QWeakPointer<MobileWidgetsExplorer> m_widgetsExplorer;
    QWeakPointer<ActivityConfiguration> m_activityConfiguration;
    bool m_isDesktop;

    KStartupInfo *m_startupInfo;
    QWeakPointer<BusyWidget> m_busyWidget;
};

#endif // multiple inclusion guard

