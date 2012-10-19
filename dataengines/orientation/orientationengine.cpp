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


#include "orientationengine.h"
#include "orientationservice.h"

#include <QtSensors/QOrientationSensor>

#include <X11/Xlib.h>
#include <X11/extensions/XInput.h>
#include <X11/extensions/XInput2.h>

#include <kdebug.h>

K_EXPORT_PLASMA_DATAENGINE(orientationengine, OrientationEngine)

using namespace QtMobility;

OrientationEngine::OrientationEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    setMaxSourceCount(64); // Guard against loading too many connections

    // This prevents applets from setting an unnecessarily high
    // update interval and using too much CPU.
    // In the case of a clock that only has second precision,
    // a third of a second should be more than enough.
    setMinimumPollingInterval(333);
}

Plasma::Service *OrientationEngine::serviceForSource(const QString &source)
{
    if (m_touchscreens.contains(source))
    {
        OrientationService *service =
          new OrientationService(m_touchscreens.value(source),
                                 containerForSource(source));
        service->setParent(this);
        return service;
    }
    return NULL;
}

void OrientationEngine::init()
{
    m_sensor = new QOrientationSensor(this);
    connect(m_sensor, SIGNAL(readingChanged()), this, SLOT(onReadingChange()));
    m_sensor->start();

    Display * display = XOpenDisplay(0);
    int ndevices_return;
    XDeviceInfo *devices = XListInputDevices( display, &ndevices_return);

    kDebug() << "Got " << ndevices_return << " X input devices";
    int foundScreen = 0;
    for (int i = 0; i < ndevices_return; ++i)
    {
        if (devices[i].type == XInternAtom(display, XI_TOUCHSCREEN, False)
           || devices[i].type == XInternAtom(display, XI_TOUCHPAD, FALSE))
        {
            QString name = QString("Screen%1").arg(foundScreen);
            kDebug() << "Got a touchscreen device " << devices[i].name;
            m_touchscreens.insert(name, devices[i].id);
            setData(name, "Orientation", 0);
            ++foundScreen;
        }
    }

    XFreeDeviceList(devices);
}

OrientationEngine::~OrientationEngine()
{
}

void OrientationEngine::onReadingChange()
{
    QOrientationReading* reading = m_sensor->reading();
    if (reading != 0)
    {
        kDebug() << "Orientation reading changed to " << reading->orientation();
        switch (reading->orientation())
        {
        case QOrientationReading::TopDown:
            //set_matrix(k_inverted_matrix);
            break;
        case QOrientationReading::LeftUp:
            //set_matrix(k_left_matrix);
            break;
        case QOrientationReading::RightUp:
            //set_matrix(k_right_matrix);
            break;
        case QOrientationReading::TopUp:
        default:
            //set_matrix(k_normal_matrix);
            break;
        }
    }
}

#include "orientationengine.moc"
