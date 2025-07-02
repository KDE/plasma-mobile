// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQuickWindow>
#include <QWindow>

#include "qqml.h"

class WaylandAboveLockscreen;

/**
 * A plugin to implement raising windows over the lockscreen.
 */
class RaiseLockscreen : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QWindow *window READ window WRITE setWindow NOTIFY windowChanged)
    Q_PROPERTY(bool initialized READ initialized NOTIFY initializedChanged)
    QML_ELEMENT

public:
    RaiseLockscreen(QObject *parent = nullptr);
    ~RaiseLockscreen() override;

    QWindow *window() const;
    void setWindow(QWindow *window);

    bool initialized() const;

    Q_INVOKABLE void initializeOverlay(QQuickWindow *window);
    Q_INVOKABLE void raiseOverlay();

Q_SIGNALS:
    void windowChanged();
    void initializedChanged();

private:
    void setInitialized(bool initialized);
    void setOverlay();
    bool eventFilter(QObject *watched, QEvent *event) override;

    bool m_initialized = false;
    QWindow *m_window = nullptr;
    int m_serial = 0;
    std::unique_ptr<WaylandAboveLockscreen> m_implementation;
};
