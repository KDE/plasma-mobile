/*
 *  calendarmigrator.cpp  -  migrates or creates KAlarm Akonadi resources
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

#include "calendarcreator.h"
#include "kalarmsettings.h"
#include "kalarmdirsettings.h"

#include <Akonadi/AgentInstance>
#include <Akonadi/AgentInstanceCreateJob>
#include <akonadi/collectionfetchscope.h>
#include <Akonadi/CollectionFetchJob>
#include <akonadi/resourcesynchronizationjob.h>
#include <akonadi/entitydisplayattribute.h>
#include <akonadi/collectionmodifyjob.h>
#include <akonadi/agentmanager.h>

#include <KLocale>
#include <KStandardDirs>

#include <kalarmcal/collectionattribute.h>

using namespace KAlarmCal;
using namespace Akonadi;


/******************************************************************************
* Constructor to migrate a KResources calendar, using its parameters.
*/
CalendarCreator::CalendarCreator(const QString& resourceType, const KConfigGroup& config)
    : mAlarmType(CalEvent::EMPTY),
      mNew(false),
      mFinished(false)
{
    // Read the resource configuration parameters from the config
    const char* pathKey = 0;
    if (resourceType == QLatin1String("file"))
    {
        mResourceType = LocalFile;
        pathKey = "CalendarURL";
    }
    else if (resourceType == QLatin1String("dir"))
    {
        mResourceType = LocalDir;
        pathKey = "CalendarURL";
    }
    else if (resourceType == QLatin1String("remote"))
    {
        mResourceType = RemoteFile;
        pathKey = "DownloadUrl";
    }
    else
    {
        kError() << "Invalid resource type:" << resourceType;
        return;
    }
    mPath = config.readPathEntry(pathKey, "");
    switch (config.readEntry("AlarmType", (int)0))
    {
        case 1:  mAlarmType = CalEvent::ACTIVE;  break;
        case 2:  mAlarmType = CalEvent::ARCHIVED;  break;
        case 4:  mAlarmType = CalEvent::TEMPLATE;  break;
        default:
            kError() << "Invalid alarm type for resource";
            return;
    }
    mName     = config.readEntry("ResourceName", QString());
    mColour   = config.readEntry("Color", QColor());
    mReadOnly = config.readEntry("ResourceIsReadOnly", true);
    mEnabled  = config.readEntry("ResourceIsActive", false);
    mStandard = config.readEntry("Standard", false);
    kDebug() << "Migrating:" << mName << ", type=" << mAlarmType << ", path=" << mPath;
}

/******************************************************************************
* Constructor to create a new default local file resource.
* This is created as enabled, read-write, and standard for its alarm type.
*/
CalendarCreator::CalendarCreator(CalEvent::Type alarmType, const QString& file, const QString& name)
    : mAlarmType(alarmType),
      mResourceType(LocalFile),
      mName(name),
      mColour(),
      mReadOnly(false),
      mEnabled(true),
      mStandard(true),
      mNew(true),
      mFinished(false)
{
    mPath = KStandardDirs::locateLocal("appdata", file);
    kDebug() << "New:" << mName << ", type=" << mAlarmType << ", path=" << mPath;
}

/******************************************************************************
* Create the Akonadi agent for this calendar.
*/
void CalendarCreator::createAgent(const QString& agentType, QObject* parent)
{
    emit creating(mPath);
    AgentInstanceCreateJob* job = new AgentInstanceCreateJob(agentType, parent);
    connect(job, SIGNAL(result(KJob*)), SLOT(agentCreated(KJob*)));
    job->start();
}

/******************************************************************************
* Called when the agent creation job for this resource has completed.
* Applies the calendar resource configuration to the Akonadi agent.
*/
void CalendarCreator::agentCreated(KJob* j)
{
    if (j->error())
    {
        mErrorMessage = j->errorString();
        kError() << "AgentInstanceCreateJob error:" << mErrorMessage;
        finish(false);
        return;
    }

    // Configure the Akonadi Agent
    kDebug() << mName;
    AgentInstanceCreateJob* job = static_cast<AgentInstanceCreateJob*>(j);
    mAgent = job->instance();
    mAgent.setName(mName);
    bool ok = false;
    switch (mResourceType)
    {
        case LocalFile:
            ok = migrateLocalFile();
            break;
        case LocalDir:
            ok = migrateLocalDirectory();
            break;
        case RemoteFile:
            ok = migrateRemoteFile();
            break;
        default:
            kError() << "Invalid resource type";
            break;
    }
    if (!ok)
    {
        finish(true);
        return;
    }
    mAgent.reconfigure();   // notify the agent that its configuration has been changed

    // Wait for the resource to create its collection.
    ResourceSynchronizationJob* sjob = new ResourceSynchronizationJob(mAgent);
    connect(sjob, SIGNAL(result(KJob*)), SLOT(resourceSynchronised(KJob*)));
    sjob->start();   // this is required (not an Akonadi::Job)
}

/******************************************************************************
* Called when a resource synchronisation job has completed.
* Fetches the collection which this agent manages.
*/
void CalendarCreator::resourceSynchronised(KJob* j)
{
    kDebug() << mName;
    if (j->error())
    {
        // Don't give up on error - we can still try to fetch the collection
        kError() << "ResourceSynchronizationJob error: " << j->errorString();
    }
    mCollectionFetchRetryCount = 0;
    fetchCollection();
}

/******************************************************************************
* Find the collection which this agent manages.
*/
void CalendarCreator::fetchCollection()
{
    CollectionFetchJob* job = new CollectionFetchJob(Collection::root(), CollectionFetchJob::FirstLevel);
    job->fetchScope().setResource(mAgent.identifier());
    connect(job, SIGNAL(result(KJob*)), SLOT(collectionFetchResult(KJob*)));
    job->start();
}

bool CalendarCreator::migrateLocalFile()
{
    OrgKdeAkonadiKAlarmSettingsInterface* iface = migrateBasic<OrgKdeAkonadiKAlarmSettingsInterface>();
    if (!iface)
        return false;
    iface->setMonitorFile(true);
    iface->writeConfig();   // save the Agent config changes
    delete iface;
    return true;
}

bool CalendarCreator::migrateLocalDirectory()
{
    OrgKdeAkonadiKAlarmDirSettingsInterface* iface = migrateBasic<OrgKdeAkonadiKAlarmDirSettingsInterface>();
    if (!iface)
        return false;
    iface->setMonitorFiles(true);
    iface->writeConfig();   // save the Agent config changes
    delete iface;
    return true;
}

bool CalendarCreator::migrateRemoteFile()
{
    OrgKdeAkonadiKAlarmSettingsInterface* iface = migrateBasic<OrgKdeAkonadiKAlarmSettingsInterface>();
    if (!iface)
        return false;
    iface->setMonitorFile(true);
    iface->writeConfig();   // save the Agent config changes
    delete iface;
    return true;
}

template <class Interface> Interface* CalendarCreator::migrateBasic()
{
    Interface* iface = getAgentInterface<Interface>(mAgent, mErrorMessage, this);
    if (iface)
    {
        iface->setReadOnly(mReadOnly);
        iface->setDisplayName(mName);
        iface->setPath(mPath);
        iface->setAlarmTypes(CalEvent::mimeTypes(mAlarmType));
        iface->setUpdateStorageFormat(false);
    }
    return iface;
}

/******************************************************************************
* Create a D-Bus interface to an Akonadi resource.
* Reply = interface if success
*       = 0 if error: 'errorMessage' contains the error message.
*/
template <class Interface> Interface* CalendarCreator::getAgentInterface(const AgentInstance& agent, QString& errorMessage, QObject* parent)
{
    Interface* iface = new Interface("org.freedesktop.Akonadi.Resource." + agent.identifier(),
              "/Settings", QDBusConnection::sessionBus(), parent);
    if (!iface->isValid())
    {
        errorMessage = iface->lastError().message();
        kDebug() << "D-Bus error accessing resource:" << errorMessage;
        delete iface;
        return 0;
    }
    return iface;
}

/******************************************************************************
* Called when a collection fetch job has completed.
* Obtains the collection handled by the agent, and configures it.
*/
void CalendarCreator::collectionFetchResult(KJob* j)
{
    kDebug() << mName;
    if (j->error())
    {
        mErrorMessage = j->errorString();
        kError() << "CollectionFetchJob error: " << mErrorMessage;
        finish(true);
        return;
    }
    CollectionFetchJob* job = static_cast<CollectionFetchJob*>(j);
    Collection::List collections = job->collections();
    if (collections.isEmpty())
    {
        if (++mCollectionFetchRetryCount >= 10)
        {
            mErrorMessage = i18nc("@info/plain", "New configuration timed out");
            kError() << "Timeout fetching collection for resource";
            finish(true);
            return;
        }
        // Need to wait a bit longer until the resource has initialised and
        // created its collection. Retry after 200ms.
        kDebug() << "Retrying";
        QTimer::singleShot(200, this, SLOT(fetchCollection()));
        return;
    }
    if (collections.count() > 1)
    {
        mErrorMessage = i18nc("@info/plain", "New configuration was corrupt");
        kError() << "Wrong number of collections for this resource:" << collections.count();
        finish(true);
        return;
    }

    // Set Akonadi Collection attributes
    Collection collection = collections[0];
    collection.setContentMimeTypes(CalEvent::mimeTypes(mAlarmType));
    EntityDisplayAttribute* dattr = collection.attribute<EntityDisplayAttribute>(Collection::AddIfMissing);
    dattr->setIconName("kalarm");
    CollectionAttribute* attr = collection.attribute<CollectionAttribute>(Entity::AddIfMissing);
    attr->setEnabled(mEnabled ? mAlarmType : CalEvent::EMPTY);
    if (mStandard)
        attr->setStandard(mAlarmType);
    if (mColour.isValid())
        attr->setBackgroundColor(mColour);

    // Update the calendar to the current KAlarm format if necessary,
    // and if the user agrees.
    bool dirResource = false;
    switch (mResourceType)
    {
        case LocalFile:
        case RemoteFile:
            break;
        case LocalDir:
            dirResource = true;
            break;
        default:
            Q_ASSERT(0); // Invalid resource type
            break;
    }
    //FIXME: port away of calendarupdater
    bool keep = true;
    bool duplicate = false;
    if (!mReadOnly)
    {
/*        CalendarUpdater* updater = new CalendarUpdater(collection, dirResource, false, true, this);
        duplicate = updater->isDuplicate();
        keep = !updater->update();   // note that 'updater' will auto-delete when finished*/
    }
    if (!duplicate)
    {
        // Record the user's choice of whether to update the calendar
        attr->setKeepFormat(keep);
    }

    // Update the collection's CollectionAttribute value in the Akonadi database.
    // Note that we can't supply 'collection' to CollectionModifyJob since
    // that also contains the CompatibilityAttribute value, which is read-only
    // for applications. So create a new Collection instance and only set a
    // value for CollectionAttribute.
    Collection c(collection.id());
    CollectionAttribute* att = c.attribute<CollectionAttribute>(Entity::AddIfMissing);
    *att = *attr;
    CollectionModifyJob* cmjob = new CollectionModifyJob(c, this);
    connect(cmjob, SIGNAL(result(KJob*)), this, SLOT(modifyCollectionJobDone(KJob*)));
}

/******************************************************************************
* Called when a collection modification job has completed.
* Checks for any error.
*/
void CalendarCreator::modifyCollectionJobDone(KJob* j)
{
    Collection collection = static_cast<CollectionModifyJob*>(j)->collection();
    if (j->error())
    {
        mErrorMessage = j->errorString();
        kError() << "CollectionFetchJob error: " << mErrorMessage;
        finish(true);
    }
    else
    {
        kDebug() << "Completed:" << mName;
        finish(false);
    }
}

/******************************************************************************
* Emit the finished() signal. If 'cleanup' is true, delete the newly created
* but incomplete Agent.
*/
void CalendarCreator::finish(bool cleanup)
{
    if (!mFinished)
    {
        if (cleanup)
            AgentManager::self()->removeInstance(mAgent);
        mFinished = true;
        emit finished(this);
    }
}

#include "calendarcreator.moc"

// vim: et sw=4:
