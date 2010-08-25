
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
        m_keyboard->show();
        return true;
    } else if (event->type() == QEvent::CloseSoftwareInputPanel) {
        m_keyboard->hide();
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

