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

#include "orientationjob.h"

#include <kscreen/config.h>

#include <QtSensors/QOrientationSensor>

#include <KDebug>

#include <X11/Xlib.h>
#include <X11/extensions/XInput.h>
#include <X11/extensions/XInput2.h>

using namespace QtMobility;

static const float k_normal_matrix[9]   = {1, 0, 0, 0, 1, 0, 0, 0, 1};
static const float k_left_matrix[9]     = {0, -1, 1, 1, 0, 0, 0, 0, 1};
static const float k_right_matrix[9]    = {0, 1, 0, -1, 0, 1, 0, 0, 1};
static const float k_inverted_matrix[9] = {-1, 0, 1, 0, -1, 1, 0, 0, 1};
static const int k_matrix_length = 9;

OrientationJob::OrientationJob(XID id,
                               int reading,
                               const QString &operation,
                               QMap<QString, QVariant> &parameters,
                               QObject *parent) :
    ServiceJob(parent->objectName(), operation, parameters, parent),
    m_id(id),
    m_prevReading((QOrientationReading::Orientation)reading)
{
    kDebug() << "Orientation job created with xid " << id << " and operation " << operation
             << " previous reading is " << m_prevReading;

}

OrientationJob::~OrientationJob()
{
}

void OrientationJob::start()
{
    const QString operation = operationName();
    kDebug() << "OrientationJob started with operation name " << operation
             << " and previous orientation " << m_prevReading;

    // Default to top up for all operations.
    QOrientationReading::Orientation direction = QOrientationReading::TopUp;
    if (operation == "setOrientation") {
        direction = (QOrientationReading::Orientation)
            parameters()["orientation"].value<int>();
    }
    else if (operation == "rotateLeft") {
        // Set direction to whatever is left of the previous reading.
        switch (m_prevReading)
        {
        case QOrientationReading::TopDown:
            direction = QOrientationReading::RightUp;
            break;
        case QOrientationReading::LeftUp:
            direction = QOrientationReading::TopDown;
            break;
        case QOrientationReading::RightUp:
            direction = QOrientationReading::TopUp;
            break;
        case QOrientationReading::TopUp:
        default:
            direction = QOrientationReading::LeftUp;
        }
    }
    else if (operation == "rotateRight") {
        // Set direction to whatever is right of the previous reading.
        switch (m_prevReading)
        {
        case QOrientationReading::TopDown:
            direction = QOrientationReading::LeftUp;
            break;
        case QOrientationReading::LeftUp:
            direction = QOrientationReading::TopUp;
            break;
        case QOrientationReading::RightUp:
            direction = QOrientationReading::TopDown;
            break;
        case QOrientationReading::TopUp:
        default:
            direction = QOrientationReading::RightUp;
        }
    }
    KScreen::Config* config = KScreen::Config::current();
    if (config == 0)
    {
        setenv("KSCREEN_BACKEND", "XRandR", 0);
        config = KScreen::Config::current();
        Q_ASSERT(config != 0);
    }
    KScreen::Output* output = config->primaryOutput();
    if (output == 0)
    {
        // There's not a primary output, so just take the first connected output.
        QHash<int, KScreen::Output*> connected = config->connectedOutputs();
        if (connected.size() < 1)
            return;
        output = (*connected.begin());
    }
    kDebug() << "direction is " << direction;
    switch (direction)
    {
    case QOrientationReading::TopDown:
        set_matrix(k_inverted_matrix);
        kDebug() << "rotating upside down";
        output->setRotation(KScreen::Output::Inverted);
        break;
    case QOrientationReading::LeftUp:
        set_matrix(k_left_matrix);
        kDebug() << "rotating left";
        output->setRotation(KScreen::Output::Left);
        break;
    case QOrientationReading::RightUp:
        set_matrix(k_right_matrix);
        kDebug() << "rotating right";
        output->setRotation(KScreen::Output::Right);
        break;
    default:
    case QOrientationReading::TopUp:
        set_matrix(k_normal_matrix);
        kDebug() << "rotating normal";
        output->setRotation(KScreen::Output::None);
        break;
    }
    KScreen::Config::setConfig(config);
    emit dataChanged(direction);
    setResult(true);
}

void OrientationJob::set_matrix (const float * values)
{
    Display * display = XOpenDisplay(0);
    Atom property = XInternAtom(display, "Coordinate Transformation Matrix", False);
    Atom old_type;
    int old_format;
    unsigned long nitems, bytes_after;

    union {
        unsigned char *c;
        long *l;
    } data;

    XDevice *device = XOpenDevice(display, m_id);
    if (XGetDeviceProperty(display, device, property, 0, 0, False,
                           AnyPropertyType, &old_type, &old_format, &nitems,
                           &bytes_after, &data.c) == Success)
    {
        XFree(data.c);
        data.c = (unsigned char*)calloc(k_matrix_length, sizeof(long));

        for (int i = 0; i < k_matrix_length; ++i)
        {
            kDebug() << "value " << values[i] << " for " << i;
            *(float*)(data.l + i) = values[i];
        }

        XChangeDeviceProperty (display, device, property, old_type,
                               old_format, PropModeReplace, data.c,
                               k_matrix_length);
        XFlush(display);
        free(data.c);
    }
    else
    {
        kDebug() << "Failed to get device property";
    }
    XCloseDevice(display, device);
}


#include "orientationjob.moc"
