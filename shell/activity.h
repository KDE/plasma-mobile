/*
 *   Copyright 2010 Chani Armitage <chani@kde.org>
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
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef ACTIVITY_H
#define ACTIVITY_H

#include <QObject>
#include <QHash>

#include <Activities/Info>

class QSize;
class QString;
class QPixmap;
class KConfig;

namespace Activities {
    class Consumer;
}

namespace Plasma
{
    class Containment;
    class Context;
} // namespace Plasma

class DesktopCorona;

/**
 * This class represents one activity.
 * an activity has an ID and a name, from nepomuk.
 * it also is associated with one or more containments.
 *
 * do NOT construct these yourself; use DesktopCorona::activity()
 */
class Activity : public QObject
{
    Q_OBJECT
public:
    Activity(const QString &id, QObject *parent = 0);
    ~Activity();

    QString id();
    QString name();
    QPixmap pixmap(const QSize &size); //FIXME do we want diff. sizes? updates?

    /**
     * whether this is the currently active activity
     */
    bool isCurrent();
    /**
     * state of the activity
     */
    Activities::Info::State state();

    /**
     * save (copy) the activity out to an @p external config
     */
    void save(KConfig &external);

    /**
     * return the containment that belongs on @p screen and @p desktop
     * or null if none exists
     */
     Plasma::Containment* containmentForScreen(int screen, int desktop = -1);

    /**
     * make this activity's containments the active ones, loading them if necessary
     */
    void ensureActive();

    /**
     * set the plugin to use when creating new containments
     */
    void setDefaultPlugin(const QString &plugin);

    /**
     * @returns the info object for this activity
     */
    const Activities::Info * info() const;

signals:
    void infoChanged();
    void stateChanged();
    void currentStatusChanged();

public slots:
    void setName(const QString &name);
    void setIcon(const QString &icon);

    /**
     * delete the activity forever
     */
    void remove();

    /**
     * make this activity the current activity
     */
    void activate();

    /**
     * save and remove all our containments
     */
    void close();

    /**
     * load the saved containment(s) for this activity
     */
    void open();

    /**
     * forcibly insert a containment, replacing the one on its screen/desktop
     */
    void replaceContainment(Plasma::Containment* containment);

private slots:
    void updateActivityName(Plasma::Context *context);
    void containmentDestroyed(QObject *object);
    void activityChanged();
    void activityStateChanged(Activities::Info::State);
    void checkIfCurrent();

    void removed();
    void opened();
    void closed();

private:
    void insertContainment(Plasma::Containment* cont, bool force=false);
    void insertContainment(Plasma::Containment* containment, int screen, int desktop);
    void checkScreens();

    QString m_id;
    QString m_name;
    QString m_icon;
    QString m_plugin;
    QHash<QPair<int,int>, Plasma::Containment*> m_containments;
    Activities::Info *m_info;
    Activities::Consumer *m_activityConsumer;
    bool m_current;
};

#endif
