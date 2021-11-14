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

#include <QtCore/QScopedPointer>
#include <QtGui/QTouchEvent>

/*
 A touch event with touch points that do not belong the item receiving it.

 See TouchRegistry::addCandidateOwnerForTouch and TouchRegistry::addTouchWatcher
 */
class UnownedTouchEvent : public QEvent
{
public:
    UnownedTouchEvent(QTouchEvent *touchEvent);
    static Type unownedTouchEventType();

    // TODO: It might be cleaner to store the information directly in UnownedTouchEvent
    //       instead of carrying around a synthesized QTouchEvent. But the latter option
    //       is very convenient.
    QTouchEvent *touchEvent();

private:
    static Type m_unownedTouchEventType;
    QScopedPointer<QTouchEvent> m_touchEvent;
};
