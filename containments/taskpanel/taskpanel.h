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

class QDBusPendingCallWatcher;

namespace KWayland
{
namespace Client
{
class PlasmaWindowManagement;
}
}

class TaskPanel : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool showDesktop READ isShowingDesktop WRITE requestShowingDesktop NOTIFY showingDesktopChanged)

public:
    TaskPanel( QObject *parent, const QVariantList &args );
    ~TaskPanel();

    Q_INVOKABLE void executeScript(const QString &script);

    bool isShowingDesktop() const {
        return m_showingDesktop;
    }
    void requestShowingDesktop(bool showingDesktop);

Q_SIGNALS:
    void showingDesktopChanged(bool);

private Q_SLOTS:
    void loadScriptFinishedSlot(QDBusPendingCallWatcher *watcher);

private:
    void initWayland();
    bool m_showingDesktop;
    KWayland::Client::PlasmaWindowManagement *m_windowManagement;

};

#endif
