/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

#ifndef FIRSTRUN_H
#define FIRSTRUN_H

#include <QObject>
#include <QStringList>
#include <QUrl>

namespace Plasma {
    class DataEngine;
}

namespace KActivities {
    class Controller;
}

class QDBusServiceWatcher;

class FirstRun: public QObject
{
    Q_OBJECT;

    public:
        FirstRun(QObject *parent = 0);
        ~FirstRun();


    Q_SIGNALS:
        void done();

    private Q_SLOTS:
        void serviceRegistered(const QString &service);
        void init();
        void activityAdded(const QString& source);
        void markDone();

    private:
        void connectToActivity(const QString &activityId, const QString &resourceUrl, const QString &description = QString());
        QDBusServiceWatcher *m_queryServiceWatcher;
        KActivities::Controller *m_activityController;
        QString m_currentActivity;
        QStringList m_initialActivities;
        QStringList m_completedActivities;

};

#endif
