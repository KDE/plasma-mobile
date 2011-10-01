/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef MOBILEACTIVITYTHUMBNAILS_H
#define MOBILEACTIVITYTHUMBNAILS_H

#include <Plasma/DataEngine>

class QTimer;
namespace Activities {
    class Consumer;
}

namespace Plasma {
    class Containment;
}

class MobileActivityThumbnails : public Plasma::DataEngine
{
    Q_OBJECT

public:
    MobileActivityThumbnails(QObject *parent, const QVariantList &args);
    void snapshotContainment(Plasma::Containment *containtment);

protected:
    bool sourceRequestEvent(const QString &source);

protected Q_SLOTS:
    void imageScaled(const QString &activity, const QImage &image);

private:

    Activities::Consumer *m_consumer;
};

#endif
