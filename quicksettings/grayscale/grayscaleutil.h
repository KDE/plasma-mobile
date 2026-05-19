/*
 * SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <KSharedConfig>
#include <KConfigWatcher>

#include <qqmlregistration.h>

class GrayscaleUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool grayscaleEnabled READ grayscaleEnabled NOTIFY grayscaleChanged);

public:
    GrayscaleUtil(QObject *parent = nullptr);
    ~GrayscaleUtil();

    Q_INVOKABLE void grayscaleToggle();
    [[nodiscard]] bool grayscaleEnabled() const;

Q_SIGNALS:
    void grayscaleChanged();

private:
    bool m_enabled;
    KSharedConfigPtr m_config;
    KConfigWatcher::Ptr m_configWatcher;

    void loadConfig();
};
