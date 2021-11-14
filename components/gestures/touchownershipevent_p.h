/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once

#include <QtCore/QEvent>

/*
   When an item get an ownership event for a touch it can grab/steal that touch
   with a clean conscience.
 */
class TouchOwnershipEvent : public QEvent
{
public:
    TouchOwnershipEvent(int touchId, bool gained);

    static Type touchOwnershipEventType();

    /*
      Whether ownership was gained (true) or lost (false)
     */
    bool gained() const
    {
        return m_gained;
    }

    /*
        Id of the touch whose ownership was granted.
     */
    int touchId() const
    {
        return m_touchId;
    }

private:
    static Type m_touchOwnershipType;
    int m_touchId;
    bool m_gained;
};
