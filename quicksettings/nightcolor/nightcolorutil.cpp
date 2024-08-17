/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "nightcolorutil.h"

NightColorUtil::NightColorUtil(QObject *parent)
    : QObject{parent}
    , m_ccInterface{new OrgKdeKWinNightLightInterface(QStringLiteral("org.kde.KWin.NightLight"),
                                                      QStringLiteral("/org/kde/KWin/NightLight"),
                                                      QDBusConnection::sessionBus(),
                                                      this)}
    , m_settings{new NightColorSettings(this)}
{
    if (!m_ccInterface->isValid()) {
        qWarning() << "Can't connect to nightcolor over DBus!";
    } else {
        m_enabled = m_ccInterface->running();

        // subscribe to property updates
        QDBusConnection::sessionBus().connect(QStringLiteral("org.kde.KWin.NightLight"),
                                              QStringLiteral("/org/kde/KWin/NightLight"),
                                              QStringLiteral("org.freedesktop.DBus.Properties"),
                                              QStringLiteral("PropertiesChanged"),
                                              this,
                                              SLOT(enabledUpdated(QString, QVariantMap, QStringList)));
    }
}

bool NightColorUtil::enabled()
{
    return m_enabled;
}

void NightColorUtil::setEnabled(bool enabled)
{
    m_settings->setMode(ColorCorrect::NightColorMode::Constant);
    m_settings->setActive(enabled);
    m_settings->save();
}

void NightColorUtil::enabledUpdated(const QString &name, const QVariantMap &map, const QStringList &list)
{
    Q_UNUSED(name)
    Q_UNUSED(map)
    Q_UNUSED(list)
    bool running = m_ccInterface->running();
    if (running != m_enabled) {
        m_enabled = running;
        Q_EMIT enabledChanged();
    }
}
