/*
 * Copyright 2009 Chani Armitage <chani@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef TASKSERVICE_H
#define TASKSERVICE_H

// plasma
#include <Plasma/Service>
#include <Plasma/ServiceJob>

// own
#include "appsource.h"

/**
 * App Service
 */
class AppService : public Plasma::Service
{

    Q_OBJECT

    public:
        AppService(AppSource *source);
        ~AppService();

    protected:
        Plasma::ServiceJob *createJob(const QString &operation, QMap<QString, QVariant> &parameters);

    private:
        AppSource *m_source;
};

#endif // TASKSERVICE_H
