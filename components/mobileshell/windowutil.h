/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QPointer>
#include <QTimer>

#include <KConfigWatcher>
#include <KSharedConfig>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

class WindowUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool showDesktop READ isShowingDesktop WRITE requestShowingDesktop NOTIFY showingDesktopChanged)
    Q_PROPERTY(bool allWindowsMinimized READ allWindowsMinimized NOTIFY allWindowsMinimizedChanged)
    Q_PROPERTY(bool hasCloseableActiveWindow READ hasCloseableActiveWindow NOTIFY hasCloseableActiveWindowChanged)
    Q_PROPERTY(bool activeWindowIsShell READ activeWindowIsShell NOTIFY activeWindowIsShellChanged)

public:
    WindowUtil(QObject *parent = nullptr);
    static WindowUtil *instance();

    bool isShowingDesktop() const;
    bool allWindowsMinimized() const;
    bool activeWindowIsShell() const;

    bool hasCloseableActiveWindow() const;
    Q_INVOKABLE void closeActiveWindow();
    Q_INVOKABLE void requestShowingDesktop(bool showingDesktop);

Q_SIGNALS:
    void windowCreated(KWayland::Client::PlasmaWindow *window);
    void showingDesktopChanged(bool showingDesktop);
    void allWindowsMinimizedChanged();
    void hasCloseableActiveWindowChanged();
    void activeWindowChanged();
    void activeWindowIsShellChanged();

private Q_SLOTS:
    void updateActiveWindowIsShell();
    void forgetActiveWindow();
    void updateShowingDesktop(bool showing);

private:
    void initWayland();
    void updateActiveWindow();

    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
    QPointer<KWayland::Client::PlasmaWindow> m_activeWindow;
    QTimer *m_activeWindowTimer;

    bool m_showingDesktop = false;
    bool m_allWindowsMinimized = true;
    bool m_activeWindowIsShell = false;
};
