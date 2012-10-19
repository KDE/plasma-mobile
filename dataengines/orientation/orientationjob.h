/*
 * Copyright 2012 Jeremy Whiting <jpwhiting@kde.org>
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

#ifndef ORIENTATION_JOB_H
#define ORIENTATION_JOB_H

// plasma
#include <Plasma/ServiceJob>
#include <X11/X.h>
#include <fixx11h.h>
#include <QtSensors/QOrientationSensor>

class OrientationJob : public Plasma::ServiceJob
{

    Q_OBJECT

    public:
        OrientationJob(XID id, int reading, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent = 0);
        ~OrientationJob();

    Q_SIGNALS:
        void dataChanged(int);

    protected:
        void start();

    private:
        void set_matrix(const float *value);
        XID m_id;
        QtMobility::QOrientationReading::Orientation m_prevReading;
};

#endif // TASKJOB_H
