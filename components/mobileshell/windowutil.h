/*
 *  SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>

#include <KConfigWatcher>
#include <KSharedConfig>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

/**
 * Utility class that provides useful functions related to windows and KWin+KWayland.
 *
 * TODO: Add per-screen support
 *
 * @author Devin Lin <devin@kde.org>
 **/
class WindowUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool showDesktop READ isShowingDesktop WRITE requestShowingDesktop NOTIFY showingDesktopChanged)
    Q_PROPERTY(bool allWindowsMinimized READ allWindowsMinimized NOTIFY allWindowsMinimizedChanged)
    Q_PROPERTY(bool allWindowsMinimizedExcludingShell READ allWindowsMinimizedExcludingShell NOTIFY allWindowsMinimizedExcludingShellChanged)
    Q_PROPERTY(bool hasCloseableActiveWindow READ hasCloseableActiveWindow NOTIFY hasCloseableActiveWindowChanged)
    Q_PROPERTY(bool activeWindowIsShell READ activeWindowIsShell NOTIFY activeWindowIsShellChanged)

public:
    WindowUtil(QObject *parent = nullptr);
    static WindowUtil *instance();

    /**
     * Whether the shell is in "desktop showing" mode, where all windows
     * are moved aside.
     */
    bool isShowingDesktop() const;

    /**
     * Whether all windows are minimized, including shell windows.
     */
    bool allWindowsMinimized() const;

    /**
     * Whether all windows are minimized, ignoring shell windows.
     */
    bool allWindowsMinimizedExcludingShell() const;

    /**
     * Whether the active window being shown is a shell window.
     */
    bool activeWindowIsShell() const;

    /**
     * Whether the current active window can be closed.
     */
    bool hasCloseableActiveWindow() const;

    /**
     * Get the list of windows associated to a storage id.
     */
    QList<KWayland::Client::PlasmaWindow *> windowsFromStorageId(const QString &storageId) const;

    /**
     * Close the current active window.
     */
    Q_INVOKABLE void closeActiveWindow();

    /**
     * Toggle whether we are in the "desktop showing" mode.
     *
     * @param showingDesktop Whether "desktop showing" mode should be enabled.
     */
    Q_INVOKABLE void requestShowingDesktop(bool showingDesktop);

    /**
     * Minimize all windows.
     */
    Q_INVOKABLE void minimizeAll();

    /**
     * Unset minimized geometries of all windows for an item's window.
     *
     * @param parent The parent item, which is of the same window that will have geometries unset.
     */
    Q_INVOKABLE void unsetAllMinimizedGeometries(QQuickItem *parent);

Q_SIGNALS:
    void windowCreated(KWayland::Client::PlasmaWindow *window);
    void showingDesktopChanged(bool showingDesktop);
    void allWindowsMinimizedChanged();
    void allWindowsMinimizedExcludingShellChanged();
    void hasCloseableActiveWindowChanged();
    void activeWindowChanged();
    void activeWindowIsShellChanged();
    void windowChanged(QString storageId); // emitted on window open or close

private Q_SLOTS:
    void updateActiveWindowIsShell();
    void forgetActiveWindow();
    void updateShowingDesktop(bool showing);
    void windowCreatedSlot(KWayland::Client::PlasmaWindow *window);

private:
    void initWayland();
    void updateActiveWindow();

    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
    QPointer<KWayland::Client::PlasmaWindow> m_activeWindow;
    QTimer *m_activeWindowTimer;

    bool m_showingDesktop = false;
    bool m_allWindowsMinimized = true;
    bool m_allWindowsMinimizedExcludingShell = true;
    bool m_activeWindowIsShell = false;

    QHash<QString, QList<KWayland::Client::PlasmaWindow *>> m_windows; // <storageId, window>
};
