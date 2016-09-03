/***************************************************************************
 *   Copyright (C) 2015 Marco Martin <mart@kde.org>                        *
 *
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

#ifndef TASKPANEL_H
#define TASKPANEL_H

#include <Plasma/Containment>

class QAbstractItemModel;

namespace KWayland
{
namespace Client
{
class PlasmaWindowManagement;
class PlasmaWindow;
class PlasmaWindowModel;
class PlasmaShell;
class PlasmaShellSurface;
class Surface;
}
}

class TaskPanel : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool showDesktop READ isShowingDesktop WRITE requestShowingDesktop NOTIFY showingDesktopChanged)
    Q_PROPERTY(bool hasCloseableActiveWindow READ hasCloseableActiveWindow NOTIFY hasCloseableActiveWindowChanged)
    Q_PROPERTY(QWindow *panel READ panel WRITE setPanel NOTIFY panelChanged)

public:
    TaskPanel( QObject *parent, const QVariantList &args );
    ~TaskPanel();

    QWindow *panel();
    void setPanel(QWindow *panel);

    Q_INVOKABLE void closeActiveWindow();

    bool isShowingDesktop() const {
        return m_showingDesktop;
    }
    void requestShowingDesktop(bool showingDesktop);

    bool hasCloseableActiveWindow() const;

public Q_SLOTS:
    void forgetActiveWindow();

Q_SIGNALS:
    void showingDesktopChanged(bool);
    void hasCloseableActiveWindowChanged();
    void panelChanged();

private:
    void initWayland();
    void updateActiveWindow();
    bool m_showingDesktop;
    QWindow *m_panel = nullptr;
    KWayland::Client::PlasmaShellSurface *m_shellSurface = nullptr;
    KWayland::Client::Surface *m_surface = nullptr;
    KWayland::Client::PlasmaShell *m_shellInterface = nullptr;
    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
    KWayland::Client::PlasmaWindowModel *m_windowModel = nullptr;
    QPointer<KWayland::Client::PlasmaWindow> m_activeWindow;
    QTimer *m_activeTimer;
};

#endif
