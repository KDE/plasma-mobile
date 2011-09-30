/*
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
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
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef PLASMA_APP_H
#define PLASMA_APP_H

#include <QList>
#include <QMultiHash>

#include <KUniqueApplication>

#include <plasma/plasma.h>

#ifdef Q_WS_X11
#include <X11/Xlib.h>
#include <fixx11h.h>
#endif

namespace Plasma
{
    class Containment;
    class Corona;
    class View;
    class Applet;
} // namespace Plasma

class KeyboardDialog;

namespace Kephal
{
    class Screen;
}

class PlasmaApp : public KUniqueApplication
{
    Q_CLASSINFO("D-Bus Interface", "org.kde.plasma.VirtualKeyboard")
    Q_OBJECT
public:
    ~PlasmaApp();

    int newInstance();

    static PlasmaApp* self();
    static bool hasComposite();

    Plasma::Corona* corona();

public Q_SLOTS:
    // DBUS interface. if you change these methods, you MUST run:
    // qdbuscpp2xml plasmaapp.h -o org.kde.PlasmaKeyboardShell.xml
    void show();
    void hide();
    void setLocation(const QString &direction);
    void requestLayout(const QString &layout);
    void resetLayout();

private:
    PlasmaApp();
    KConfigGroup storedConfig();

private Q_SLOTS:
    void cleanup();
    void syncConfig();
    void storeApplet(Plasma::Applet *applet);
    void hideKeyboard();
    void windowChangeHide();
    void clearIgnoreNextWindowHide();

private:
    Plasma::Corona *m_corona;
    Plasma::Containment *m_containment;
    KeyboardDialog *m_dialog;
    QTimer *m_delayedHideTimer;
    QTimer *m_clearIgnoreNextWindowHideTimer;
    bool m_ignoreNextWindowHide;
};

#endif // multiple inclusion guard

