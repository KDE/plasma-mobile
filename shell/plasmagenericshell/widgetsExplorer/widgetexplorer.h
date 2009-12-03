/*
 *   Copyright (C) 2007 by Ivan Cukic <ivan.cukic+kde@gmail.com>
 *   Copyright (C) 2009 by Ana Cecília Martins <anaceciliamb@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library/Lesser General Public License
 *   version 2, or (at your option) any later version, as published by the
 *   Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library/Lesser General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#ifndef WIDGETEXPLORER_H
#define WIDGETEXPLORER_H

#include <QtGui>

#include <KDE/KDialog>

#include <plasma/framesvg.h>

#include "plasmaappletitemmodel_p.h"

#include "../plasmagenericshell_export.h"

namespace Plasma
{

class Corona;
class Containment;
class Applet;
class WidgetExplorerPrivate;
class WidgetExplorerPrivate;

class PLASMAGENERICSHELL_EXPORT WidgetExplorer : public QGraphicsWidget
{

    Q_OBJECT

public:
    WidgetExplorer(QGraphicsItem *parent = 0);
    ~WidgetExplorer();

    QString application();

    /**
     * Populates the widget list for the given application. This must be called
     * before the widget explorer will be usable as the widget list will remain
     * empty up to that point.
     *
     * @arg application the application which the widgets should be loaded for.
     */
    void populateWidgetList(const QString &application = QString());

    /**
     * Changes the current default containment to add applets to
     *
     * @arg containment the new default
     */
    void setContainment(Plasma::Containment *containment);

    /**
     * @return the current default containment to add applets to
     */
    Containment *containment() const;
    /**
     * @return the current corona this widget is added to
     */
    Plasma::Corona *corona() const;

    /**
     * Set the orientation of the widget explorer
     *
     * @arg the new orientation
     */
    void setOrientation(Qt::Orientation orientation);

    /**
     * @return the orientation of the widget explorer
     */
    Qt::Orientation orientation();

    /**
     * Sets the icon size for the widget explorer
     */
    void setIconSize(int size);

    /**
     * @return the icon size of the wiget explorer
     */
    int iconSize() const;

Q_SIGNALS:
    void orientationChanged(Qt::Orientation orientation);
    void closeClicked();

public Q_SLOTS:
    /**
     * Adds currently selected applets
     */
    void addApplet();

    /**
     * Adds applet
     */
    void addApplet(PlasmaAppletItem *appletItem);

private:
    Q_PRIVATE_SLOT(d, void appletAdded(Plasma::Applet*))
    Q_PRIVATE_SLOT(d, void appletRemoved(Plasma::Applet*))
    Q_PRIVATE_SLOT(d, void containmentDestroyed())

    WidgetExplorerPrivate * const d;

};

} // namespace Plasma

#endif // WIDGETEXPLORER_H
