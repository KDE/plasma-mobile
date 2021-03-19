/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

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
    Q_PROPERTY(bool allMinimized READ allMinimized NOTIFY allMinimizedChanged)
    Q_PROPERTY(bool hasCloseableActiveWindow READ hasCloseableActiveWindow NOTIFY hasCloseableActiveWindowChanged)
    Q_PROPERTY(QWindow *panel READ panel WRITE setPanel NOTIFY panelChanged)

public:
    TaskPanel(QObject *parent, const QVariantList &args);
    ~TaskPanel() override;

    QWindow *panel();
    void setPanel(QWindow *panel);

    Q_INVOKABLE void closeActiveWindow();

    bool isShowingDesktop() const
    {
        return m_showingDesktop;
    }
    void requestShowingDesktop(bool showingDesktop);

    bool allMinimized() const
    {
        return m_allMinimized;
    }
    bool hasCloseableActiveWindow() const;

public Q_SLOTS:
    void forgetActiveWindow();

Q_SIGNALS:
    void showingDesktopChanged(bool);
    void hasCloseableActiveWindowChanged();
    void panelChanged();
    void allMinimizedChanged();

private:
    void initWayland();
    void updateActiveWindow();
    void updatePanelVisibility();
    bool m_showingDesktop = false;
    bool m_allMinimized = true;
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
