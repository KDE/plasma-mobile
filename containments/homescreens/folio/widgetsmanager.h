// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "homescreen.h"

#include <QObject>

#include <Plasma/Applet>

// keeps a list of all of instances of Plasma::Applet that are loaded into the containment
// allows for FolioWidgets to find their corresponding Plasma::Applet
class WidgetsManager : public QObject
{
    Q_OBJECT
public:
    WidgetsManager(QObject *parent = nullptr);

    Plasma::Applet *getWidget(int id);

    void addWidget(Plasma::Applet *applet);
    void removeWidget(Plasma::Applet *applet);

Q_SIGNALS:
    void widgetAdded(Plasma::Applet *applet);
    void widgetRemoved(Plasma::Applet *applet);

private:
    QList<Plasma::Applet *> m_widgets;
};
