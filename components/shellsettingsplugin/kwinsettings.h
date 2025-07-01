/*
 *  SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>
#include <qobject.h>
#include <qqmlintegration.h>

class KWinSettings : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(KWinSettings)
    QML_SINGLETON

    Q_PROPERTY(bool doubleTapWakeup READ doubleTapWakeup WRITE setDoubleTapWakeup NOTIFY doubleTapWakeupChanged)

public:
    KWinSettings(QObject *parent = nullptr);

    /**
     * Whether Double Tap to Wakeup is enabled.
     */
    bool doubleTapWakeup() const;

    /**
     * Set whether Double Tap to Wakeup is enabled.
     *
     * @param enabled
     */
    void setDoubleTapWakeup(bool enabled);

Q_SIGNALS:
    void doubleTapWakeupChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};
