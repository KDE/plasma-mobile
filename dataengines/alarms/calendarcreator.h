/*
 *  calendarmigrator.h  -  migrates or creates KAlarm Akonadi resources
 *  Program:  kalarm
 *  Copyright © 2011-2012 by David Jarvie <djarvie@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#ifndef CALENDARCREATOR_H
#define CALENDARCREATOR_H

#include <KConfigGroup>

#include <Akonadi/AgentInstance>
#include <kalarmcal/kaevent.h>

using namespace KAlarmCal;
class KJob;

// Creates, or migrates from KResources, a single alarm calendar
class CalendarCreator : public QObject
{
        Q_OBJECT
    public:
        // Constructor to migrate a calendar from KResources.
        CalendarCreator(const QString& resourceType, const KConfigGroup&);
        // Constructor to create a default Akonadi calendar.
        CalendarCreator(CalEvent::Type, const QString& file, const QString& name);
        bool           isValid() const        { return mAlarmType != CalEvent::EMPTY; }
        CalEvent::Type alarmType() const      { return mAlarmType; }
        bool           newCalendar() const    { return mNew; }
        QString        resourceName() const   { return mName; }
        QString        path() const           { return mPath; }
        QString        errorMessage() const   { return mErrorMessage; }
        void           createAgent(const QString& agentType, QObject* parent);

    public slots:
        void agentCreated(KJob*);

    signals:
        void creating(const QString& path);
        void finished(CalendarCreator*);

    private slots:
        void fetchCollection();
        void collectionFetchResult(KJob*);
        void resourceSynchronised(KJob*);
        void modifyCollectionJobDone(KJob*);

    private:
        void finish(bool cleanup);
        bool migrateLocalFile();
        bool migrateLocalDirectory();
        bool migrateRemoteFile();
        template <class Interface> static Interface* getAgentInterface(const Akonadi::AgentInstance&, QString& errorMessage, QObject* parent);
        template <class Interface> Interface* migrateBasic();

        enum ResourceType { LocalFile, LocalDir, RemoteFile };

        Akonadi::AgentInstance mAgent;
        CalEvent::Type         mAlarmType;
        ResourceType           mResourceType;
        QString                mPath;
        QString                mName;
        QColor                 mColour;
        QString                mErrorMessage;
        int                    mCollectionFetchRetryCount;
        bool                   mReadOnly;
        bool                   mEnabled;
        bool                   mStandard;
        const bool             mNew;
        bool                   mFinished;
};

#endif // CALENDARCREATOR_H

// vim: et sw=4:
