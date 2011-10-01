/*
 * Copyright 2009 Chani Armitage <chani@kde.org>
 * Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef APPSSENGINE_H
#define APPSSENGINE_H

// plasma
#include <Plasma/DataEngine>
#include <Plasma/Service>

#include <KService>
#include <KServiceGroup>

/**
 * Apps Data Engine
 */
class AppsEngine : public Plasma::DataEngine
{
    Q_OBJECT

public:
    AppsEngine(QObject *parent, const QVariantList &args);
    ~AppsEngine();

    bool sourceRequestEvent(const QString &name);
    Plasma::Service *serviceForSource(const QString &name);
};

#endif // APPSSENGINE_H
