/***************************************************************************
 *   task.h                                                                *
 *                                                                         *
 *   Copyright (C) 2008 Jason Stubbs <jasonbstubbs@gmail.com>              *
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

#ifndef SYSTEMTRAYTASK_H
#define SYSTEMTRAYTASK_H

#include <QtCore/QObject>

#include <QtGui/QIcon>

class QGraphicsWidget;

namespace Plasma
{
    class Applet;
} // namespace Plasma

namespace SystemTray
{

/**
 * @short System tray task base class
 *
 * To support a new system tray protocol, Protocol and this class should
 * be subclassed.
 **/
class Task : public QObject
{
    Q_OBJECT

public:
    enum Order { First, Normal, Last };

    enum HideState {
        NotHidden = 0,
        UserHidden = 1,
        AutoHidden = 2
    };
    Q_DECLARE_FLAGS(HideStates, HideState)

    enum Status {
        UnknownStatus = 0,
        Passive = 1,
        Active = 2,
        NeedsAttention = 3
    };
    Q_ENUMS(Status)

    enum Category {
        UnknownCategory = 0,
        ApplicationStatus = 1,
        Communications = 2,
        SystemServices = 3,
        Hardware = 4
    };
    Q_ENUMS(Category)



    virtual ~Task();

    /**
     * Creates a new graphics widget for this task
     *
     * isEmbeddable() should be checked before creating a new widget.
     **/
    QGraphicsWidget* widget(Plasma::Applet *host, bool createIfNecessary = true);

    /**
     * @return whether this task is embeddable; true if there is already a widget
     * for this host.
     */
    bool isEmbeddable(Plasma::Applet *host);

    /**
     * Returns whether this task can be embeddable
     *
     * Depending on the protocol, there may be circumstances under which
     * a new widget can not be created. isEmbeddable() will return false
     * under these circumstances.
     **/
    virtual bool isEmbeddable() const = 0;

    /**
     * Returns the name of this task that should be presented to the user
     **/
    virtual QString name() const = 0;

    /**
     * Returns a unique identifier for this task
     *
     * The identifier is valid between restarts and so is safe to save
     **/
    virtual QString typeId() const = 0;

    /**
     * Returns an icon that can be associated with this task
     *
     * The icon returned is not necessarily the same icon that appears
     * in the tray icon itself.
     **/
    virtual QIcon icon() const = 0;

    /**
     * Returns whether the task is currently hideable by the user or not
     */
    virtual bool isHideable() const;

    /**
     * Make the task ask to be hidden. The systemtray may or may not fullfill that requirement
     */
    void setHidden(HideStates state);

    /**
     * Returns the state of the icon: visible, hidden by the user or hidden by itself
     */
    HideStates hidden() const;

    /**
     * @return true if this task is current being used, e.g. it has created
     * widgets for one or more hosts
     */
    bool isUsed() const;

    /**
     * Returns the order this Task should be placed in: first, normal or last
     */
    Order order() const;

    /**
     * Sets which order this task should be placed in, relative to other Tasks
     *
     * @arg order the order to set this Task to
     */
    void setOrder(Order order);

    /**
     * Sets the category of the task, UnknownCategory by default
     * @arg category the category for this task
     */
    void setCategory(Category category);

    /**
     * @return the category of this task
     */
    Category category() const;

    /**
     * Sets the status of the task, UnknownStatus by default.
     * @arg status the status for this task
     */
    void setStatus(Status status);

    /**
     * @return the status for this task
     */
    Status status() const;

    /**
     * Resets the hidden state based purely on the status. Will not emit a changed signal.
     */
    void resetHiddenStatus();

    QHash<Plasma::Applet *, QGraphicsWidget *> widgetsByHost() const;

Q_SIGNALS:
    /**
     * Emitted when something about the task has changed
     **/
    //TODO: this should also state _what_ was changed so we can react more
    //      precisely (and therefore with greater efficiency)
    void changed(SystemTray::Task *task);

    /**
     * Emitted when the task is about to be destroyed
     **/
    void destroyed(SystemTray::Task *task);

protected:
    Task(QObject *parent = 0);

    /**
     * Called when a new widget is required
     *
     * Subclasses should implement this to return a graphics widget that
     * handles all user interaction with the task. Ownership of the
     * created widget is handled automatically so subclasses should not
     * delete the created widget.
     **/
    virtual QGraphicsWidget* createWidget(Plasma::Applet *host) = 0;

private slots:
    void widgetDeleted();

private:
    class Private;
    Private* const d;
};

}


#endif
