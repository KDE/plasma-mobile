/***************************************************************************
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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

#include <QtCore>

#include "inputcontext.h"
#include "keyboard_interface.h"

#include <kdebug.h>


InputContext::InputContext()
{
    m_keyboard = new LocalPlasmaKeyboardInterface("org.kde.plasma-keyboardcontainer", "/App",
                                      QDBusConnection::sessionBus());
}


InputContext::~InputContext()
{
}


bool InputContext::filterEvent(const QEvent* event)
{
    if (event->type() == QEvent::RequestSoftwareInputPanel) {
        kWarning()<<"Show on screen keyboard";
        m_keyboard->call("show");
        return true;
    } else if (event->type() == QEvent::CloseSoftwareInputPanel) {
        m_keyboard->call("hide");
        kWarning()<<"hide on screen keyboard";
        return true;
    }
    return false;
}


QString InputContext::identifierName()
{
    return "InputContext";
}

void InputContext::reset()
{
}

bool InputContext::isComposing() const
{
    return false;
}

QString InputContext::language()
{
    return "en_US";
}

