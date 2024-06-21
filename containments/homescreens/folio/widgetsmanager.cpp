// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "widgetsmanager.h"

WidgetsManager::WidgetsManager(QObject *parent)
    : QObject{parent}
{
}

Plasma::Applet *WidgetsManager::getWidget(int id)
{
    for (auto *widget : m_widgets) {
        if (static_cast<int>(widget->id()) == id) {
            return widget;
        }
    }

    return nullptr;
}

void WidgetsManager::addWidget(Plasma::Applet *applet)
{
    if (!m_widgets.contains(applet)) {
        m_widgets.push_back(applet);
        Q_EMIT widgetAdded(applet);
    }
}

void WidgetsManager::removeWidget(Plasma::Applet *applet)
{
    if (m_widgets.contains(applet)) {
        m_widgets.remove(m_widgets.indexOf(applet));
        Q_EMIT widgetRemoved(applet);
    }
}
