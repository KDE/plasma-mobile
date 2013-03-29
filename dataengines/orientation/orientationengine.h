/*
    Copyright 2012 Jeremy Whiting <jpwhiting@kde.org>

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301, USA.
*/


#ifndef ORIENTATION_ENGINE_H
#define ORIENTATION_ENGINE_H

#include <Plasma/Service>
#include <Plasma/DataEngine>

#include <QStringList>
#include <X11/X.h>

namespace QtMobility
{
    class QOrientationSensor;
}

class OrientationEngine : public Plasma::DataEngine
{
    Q_OBJECT

public:
    OrientationEngine(QObject* parent, const QVariantList& args);
    ~OrientationEngine();
    Plasma::Service *serviceForSource(const QString &source);
    virtual void init();

private slots:
    void onReadingChange();
    void rotationChanged();

private:
    QtMobility::QOrientationSensor* m_sensor;
};

#endif
