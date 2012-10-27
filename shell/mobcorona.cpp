/***************************************************************************
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>                      *
 *   Copyright 2009 Marco Martin <notmart@gmail.com>                       *
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "mobcorona.h"
#include "mobdialogmanager.h"
#include "activity.h"
#include "kao.h"

#include <QApplication>
#include <QDesktopWidget>
#include <QDir>
#include <QGraphicsLayout>

#include <KCmdLineArgs>
#include <KDebug>
#include <KDialog>
#include <KGlobalSettings>
#include <KStandardDirs>

#include <Plasma/Containment>
#include <Plasma/Context>
#include <Plasma/DataEngineManager>

#include "plasmaapp.h"
#include "mobview.h"
#include <plasma/containmentactionspluginsconfig.h>

#include <Plasma/DeclarativeWidget>
#include <Plasma/Package>

#include <Nepomuk2/Resource>
#include <Nepomuk2/Variant>

#include <KActivities/Consumer>
#include <KActivities/Controller>

static const char *DEFAUL_CONTAINMENT = "org.kde.active.activityscreen";

MobCorona::MobCorona(QObject *parent)
    : Plasma::Corona(parent),
      m_activityController(new KActivities::Controller(this)),
      m_package(0)
{
    init();
}

MobCorona::~MobCorona()
{
    KConfigGroup cg(config(), "SavedContainments");

    //stop everything, in order to restore them just on demand at next boot
    const QString currentActivity = m_activityController->currentActivity();

    QHash<QString, Activity *>::const_iterator i = m_activities.constBegin();
    while (i != m_activities.constEnd()) {
        QString file = "activities/"+i.key();
        KConfig external(file, KConfig::SimpleConfig, "appdata");

        //copy the old config to the new location
        i.value()->save(external);
        if (i.key() != currentActivity) {
            i.value()->close();
        }
        ++i;
    }

    //get rid of containments and their config groups
    foreach (Plasma::Containment *cont, containments()) {
        if (cont->context()->currentActivityId() != currentActivity && cont->formFactor() == Plasma::Planar) {
            cont->config().deleteGroup();
            cont->destroy(false);
        }
    }
}

void MobCorona::init()
{
    QString homeScreenPath = KGlobal::mainComponent().componentName() + "-homescreen";
    KConfigGroup globalConfig(KGlobal::config(), "General");
    homeScreenPath = globalConfig.readEntry("HomeScreenPackage", "org.kde.active.contour-tablet-homescreen");
    kDebug()<<"Searching for the home screen"<<homeScreenPath;

    //setup package for the home screen
    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), homeScreenPath, structure);

    //if the package is invalid, don't launch the application
    if (!m_package->isValid()) {
        kWarning()<<"Invalid home screen package:"<<homeScreenPath;
        QTimer::singleShot(0, QCoreApplication::instance(), SLOT(quit()));
        return;
    }

    KConfigGroup cg(defaultConfig());
    if (cg.isValid()) {
        cg = KConfigGroup(&cg, "ContainmentDefaults");
        const QString defaultContainment = cg.readEntry("defaultContainment", DEFAUL_CONTAINMENT);
        kDebug() << "Using" << defaultContainment << "as default containment plugin";
        setDefaultContainmentPlugin(defaultContainment);
    } else {
        setDefaultContainmentPlugin(DEFAUL_CONTAINMENT);
    }

    enableAction("lock widgets", false);

    setItemIndexMethod(QGraphicsScene::NoIndex);
    setDialogManager(new MobDialogManager(this));

    connect(m_activityController, SIGNAL(currentActivityChanged(QString)), this, SLOT(currentActivityChanged(QString)));
    connect(m_activityController, SIGNAL(activityAdded(QString)), this, SLOT(activityAdded(QString)));
    connect(m_activityController, SIGNAL(activityRemoved(QString)), this, SLOT(activityRemoved(QString)));
}

KConfigGroup MobCorona::defaultConfig() const
{
    const QString defaultConfig = m_package->filePath("config", "plasma-default-layoutrc");

    //kDebug() << "============================================================================";
    //kDebug() << "layout HSP:" << homeScreenPath;
    //kDebug() << "layout RC :" << layoutRc;
    //kDebug() << "layout CFG:" << defaultConfig;
    if (!defaultConfig.isEmpty()) {
        kDebug() << "attempting to load the default layout from:" << defaultConfig;
        return KConfigGroup(new KConfig(defaultConfig), QString());
    }
    kWarning() << "Invalid layout, could not locate plasma-default-layoutrc";
    return KConfigGroup();
}

void MobCorona::loadDefaultLayout()
{
    KConfigGroup cg = defaultConfig();

    if (cg.isValid()) {
        importLayout(cg);
        return;
    }
    kWarning() << "Invalid layout, could not locate plasma-default-layoutrc";


    // FIXME: need to load the Mobile-specific containment
    // passing in an empty string will get us whatever the default
    // containment type is!
    Plasma::Containment* c = addContainmentDelayed(QString());

    if (!c) {
        return;
    }

    c->init();

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();
    bool isDesktop = args->isSet("desktop");

    if (isDesktop) {
        c->setScreen(0);
    }

    c->setWallpaper("image", "SingleImage");
    c->setFormFactor(Plasma::Planar);
    c->updateConstraints(Plasma::StartupCompletedConstraint);
    c->flushPendingConstraintsEvents();
    //cg is invalid here
    c->save(cg);

    // stacks all the containments at the same place
    c->setPos(0, 0);

    emit containmentAdded(c);
    requestConfigSync();
}

void MobCorona::layoutContainments()
{
    // we don't need any layout for this as we are going to bind the position
    // of the containments to QML items to animate them. As soon as we don't
    // need the containment anymore we can just let it stay wherever it is as
    // long as it's offscreen (the view is not 'looking' at it).

    // As this method is called from containments resize event and itemChange
    // if we let the default implementation work here we could have bad surprises
    // of containments appearing in the view when putting them in the default
    // grid-like layout.
    return;
}

Plasma::Applet *MobCorona::loadDefaultApplet(const QString &pluginName, Plasma::Containment *c)
{
    QVariantList args;
    Plasma::Applet *applet = Plasma::Applet::load(pluginName, 0, args);

    if (applet) {
        c->addApplet(applet);
    }
    return applet;
}

Plasma::Containment *MobCorona::findFreeContainment() const
{
    foreach (Plasma::Containment *cont, containments()) {
        if ((cont->containmentType() == Plasma::Containment::DesktopContainment ||
             cont->containmentType() == Plasma::Containment::CustomContainment) &&
            cont->screen() == -1 && !offscreenWidgets().contains(cont)) {
            return cont;
        }
    }
    return 0;
}

int MobCorona::numScreens() const
{
    return QApplication::desktop()->screenCount();
}

void MobCorona::setScreenGeometry(const QRect &geometry)
{
    m_screenGeometry = geometry;
}

QRect MobCorona::screenGeometry(int id) const
{
    Q_UNUSED(id)
    return m_screenGeometry;
}

void MobCorona::setAvailableScreenRegion(const QRegion &r)
{
   m_availableScreenRegion = r;
   emit availableScreenRegionChanged();
}

QRegion MobCorona::availableScreenRegion(int id) const
{
    QRegion r(screenGeometry(id));
    return m_availableScreenRegion;
    foreach (Plasma::Containment *cont, PlasmaApp::self()->panelContainments()) {
        if (cont->location() == Plasma::TopEdge ||
            cont->location() == Plasma::BottomEdge ||
            cont->location() == Plasma::LeftEdge ||
            cont->location() == Plasma::RightEdge) {
            r = r.subtracted(cont->mapToScene(cont->boundingRect()).toPolygon());
        }
    }
    return r;
}

void MobCorona::currentActivityChanged(const QString &newActivity)
{
    if (newActivity.isEmpty()) {
        return;
    }

    kDebug() << newActivity;
    Activity *act =activity(newActivity);
    if (act) {
        act->ensureActive();
    }
}

Activity* MobCorona::activity(const QString &id)
{
    if (!m_activities.contains(id)) {
        //the add signal comes late sometimes
        activityAdded(id);
    }
    return m_activities.value(id);
}

void MobCorona::activityAdded(const QString &id)
{
    //TODO more sanity checks
    if (m_activities.contains(id)) {
        kDebug() << "you're late." << id;
        return;
    }

    Activity *a = new Activity(id, this);
    if (a->isCurrent()) {
        a->ensureActive();
    }
    m_activities.insert(id, a);
}

void MobCorona::activityRemoved(const QString &id)
{
    Activity *a = m_activities.take(id);
    a->deleteLater();
}

void MobCorona::activateNextActivity()
{
    QStringList list = m_activityController->listActivities(KActivities::Info::Running);
    if (list.isEmpty()) {
        return;
    }

    //FIXME: if the current activity is in transition the "next" will be the first
    int start = list.indexOf(m_activityController->currentActivity());
    int i = (start + 1) % list.size();

    m_activityController->setCurrentActivity(list.at(i));
}

void MobCorona::activatePreviousActivity()
{
    QStringList list = m_activityController->listActivities(KActivities::Info::Running);
    if (list.isEmpty()) {
        return;
    }

    //FIXME: if the current activity is in transition the "previous" will be the last
    int start = list.indexOf(m_activityController->currentActivity());
    //fun fact: in c++, (-1 % foo) == -1
    int i = start - 1;
    if (i < 0) {
        i = list.size() - 1;
    }

    m_activityController->setCurrentActivity(list.at(i));
}

void MobCorona::checkActivities()
{
    kDebug() << "containments to start with" << containments().count();

    KActivities::Consumer::ServiceStatus status = m_activityController->serviceStatus();
    //kDebug() << "$%$%$#%$%$%Status:" << status;
    if (status == KActivities::Consumer::NotRunning) {
        //panic and give up - better than causing a mess
        kDebug() << "No ActivityManager? Help, I've fallen and I can't get up!";
        return;
    }

    QStringList existingActivities = m_activityController->listActivities();
    foreach (const QString &id, existingActivities) {
        //ensure the activity resource exists
        //FIXME: shouldn't be done here
        Nepomuk2::Resource activityResource(id, Nepomuk2::Vocabulary::KAO::Activity());
        activityResource.setProperty(Nepomuk2::Vocabulary::KAO::activityIdentifier(), id);
        activityAdded(id);
    }

    QStringList newActivities;
    QString newCurrentActivity;
    //migration checks:
    //-containments with an invalid id are deleted.
    //-containments that claim they were on a screen are kept together, and are preferred if we
    //need to initialize the current activity.
    //-containments that don't know where they were or who they were with just get made into their
    //own activity.
    foreach (Plasma::Containment *cont, containments()) {
        bool excludeFromActivities = cont->config().readEntry("excludeFromActivities", false);


        if (!excludeFromActivities && (cont->containmentType() == Plasma::Containment::DesktopContainment ||
             cont->containmentType() == Plasma::Containment::CustomContainment) &&
            !offscreenWidgets().contains(cont)) {
            Plasma::Context *context = cont->context();
            QString oldId = context->currentActivityId();
            if (!oldId.isEmpty()) {
                if (existingActivities.contains(oldId)) {
                    continue; //it's already claimed
                }
                kDebug() << "invalid id" << oldId;
                //byebye
                cont->destroy(false);
                continue;
            }
            if (cont->screen() > -1) {
                //it belongs on the current activity
                if (!newCurrentActivity.isEmpty()) {
                    context->setCurrentActivityId(newCurrentActivity);
                    continue;
                }
            }
            //discourage blank names
            if (context->currentActivity().isEmpty()) {
                context->setCurrentActivity(i18nc("Default name for a new activity", "New Activity"));
            }
            //create a new activity for the containment
            QString id = m_activityController->addActivity(context->currentActivity());
            context->setCurrentActivityId(id);
            newActivities << id;
            if (cont->screen() > -1) {
                newCurrentActivity = id;
            }
            kDebug() << "migrated" << context->currentActivityId() << context->currentActivity();

            QString activityIcon = cont->config().readEntry("activityIcon", QString());
            if (!activityIcon.isEmpty()) {
                m_activityController->setActivityIcon(id, activityIcon);
            }
        }
    }

    kDebug() << "migrated?" << !newActivities.isEmpty() << containments().count();
    if (!newActivities.isEmpty()) {
        requestConfigSync();
    }

    //init the newbies
    foreach (const QString &id, newActivities) {
        activityAdded(id);
    }

    //ensure the current activity is initialized
    if (m_activityController->currentActivity().isEmpty()) {
        kDebug() << "guessing at current activity";
        if (existingActivities.isEmpty()) {
            if (newCurrentActivity.isEmpty()) {
                if (newActivities.isEmpty()) {
                    kDebug() << "no activities!?! Bad activitymanager, no cookie!";
                    QString id = m_activityController->addActivity(i18nc("Default name for a new activity", "New Activity"));
                    activityAdded(id);
                    m_activityController->setCurrentActivity(id);
                    kDebug() << "created emergency activity" << id;
                } else {
                    m_activityController->setCurrentActivity(newActivities.first());
                }
            } else {
                m_activityController->setCurrentActivity(newCurrentActivity);
            }
        } else {
            m_activityController->setCurrentActivity(existingActivities.first());
        }
    }
}

Plasma::Package *MobCorona::homeScreenPackage() const
{
    return m_package;
}

#include "mobcorona.moc"

