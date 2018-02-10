/***************************************************************************
 *   Copyright 2015 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/
#ifndef FULLSCREENPANEL_H
#define FULLSCREENPANEL_H

#include <QQuickWindow>

namespace KWayland
{
namespace Client
{
class PlasmaWindow;
class PlasmaShell;
class PlasmaShellSurface;
class Shell;
class ShellSurface;
class Surface;
}
}

class FullScreenPanel : public QQuickWindow
{
    Q_OBJECT
    Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)

public:
    FullScreenPanel(QQuickWindow *parent = 0);
    ~FullScreenPanel();

Q_SIGNALS:
    void activeChanged();

protected:
    void showEvent(QShowEvent *event);

private:
    void initWayland();
    KWayland::Client::PlasmaShellSurface *m_plasmaShellSurface = nullptr;
    KWayland::Client::ShellSurface *m_shellSurface = nullptr;
    KWayland::Client::Surface *m_surface = nullptr;
    KWayland::Client::PlasmaShell *m_plasmaShellInterface = nullptr;
    KWayland::Client::Shell *m_shellInterface = nullptr;
};

#endif
