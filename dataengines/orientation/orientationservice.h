/*
 *   Copyright 2012 Jeremy Whiting <jpwhiting@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef ORIENTATION_SERVICE_H
#define ORIENTATION_SERVICE_H

#include "orientationengine.h"

#include <Plasma/DataContainer>
#include <Plasma/Service>
#include <Plasma/ServiceJob>
#include <X11/X.h>

class OrientationService : public Plasma::Service
{
    Q_OBJECT

public:
    OrientationService(XID id, Plasma::DataContainer *source);
    Plasma::ServiceJob *createJob(const QString &operation,
                          QMap<QString, QVariant> &parameters);

private Q_SLOTS:
    void onDataChanged(int value);

private:
    XID m_id;
    Plasma::DataContainer *m_source;
};

#endif // SEARCHLAUNCH_SERVICE_H
