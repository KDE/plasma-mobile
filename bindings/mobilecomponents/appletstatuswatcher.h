/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
 *   Copyright 2010 Alexis Menard <menard@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef APPLETSTATUSWATCHER_H
#define APPLETSTATUSWATCHER_H

#include <QObject>
#include <QWeakPointer>

namespace Plasma {
    class Applet;
}

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

#endif
