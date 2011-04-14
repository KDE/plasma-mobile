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


//FIXME: is there a better way to register enums of Plasma namespace?
class AppletStatusWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *plasmoid READ plasmoid WRITE setPlasmoid)
    Q_PROPERTY(ItemStatus status READ status WRITE setStatus NOTIFY statusChanged)
    Q_ENUMS(ItemStatus)

public:
    enum ItemStatus {
        UnknownStatus = 0, /**< The status is unknown **/
        PassiveStatus = 1, /**< The Item is passive **/
        ActiveStatus = 2, /**< The Item is active **/
        NeedsAttentionStatus = 3, /**< The Item needs attention **/
        AcceptingInputStatus = 4 /**< The Item is accepting input **/
    };

    AppletStatusWatcher(QObject *parent = 0);
    ~AppletStatusWatcher();

    void setPlasmoid(QObject *applet);
    QObject *plasmoid() const;

    void setStatus(const ItemStatus status);
    ItemStatus status() const;

Q_SIGNALS:
    void statusChanged();

private:
    QWeakPointer<Plasma::Applet> m_plasmoid;
};

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
    void lockScreen();
    void showWidgetsExplorer();
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
    QHash<Plasma::Location, Plasma::Containment *> m_panelContainments;

    MobPluginLoader *m_pluginLoader;

    QString m_homeScreenPath;
    QWeakPointer<MobileWidgetsExplorer> m_widgetsExplorer;
    bool m_isDesktop;
};

#endif // multiple inclusion guard

