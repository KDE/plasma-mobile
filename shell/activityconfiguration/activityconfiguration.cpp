/***************************************************************************
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

//own
#include "activityconfiguration.h"

//Qt
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeItem>
#include <QTimer>
#include <QGraphicsView>
#include <QApplication>
#include <QGraphicsSceneResizeEvent>

//KDE
#include <KDebug>
#include <KStandardDirs>

//Plasma
#include <Plasma/Containment>
#include <Plasma/Corona>
#include <Plasma/Context>
#include <Plasma/Package>

#ifndef NO_ACTIVITIES
#include <KActivities/Controller>
#endif

#include "backgroundlistmodel.h"
#include "plasmaapp.h"

ActivityConfiguration::ActivityConfiguration(QGraphicsWidget *parent)
    : Plasma::DeclarativeWidget(parent),
      m_containment(0),
      m_mainWidget(0),
      m_model(0),
      m_wallpaperIndex(-1),
      m_newContainment(false)
{
    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), "org.kde.active.activityconfiguration", structure);

    //setInitializationDelayed(true);
    //setQmlPath(m_package->filePath("mainscript"));
#ifndef NO_ACTIVITIES
    m_activityController = new KActivities::Controller(this);
#endif

    Plasma::Wallpaper *wp = Plasma::Wallpaper::load(bestWallpaperPluginAvailable());
    if (wp) {
        wp->setParent(this);
        wp->setTargetSizeHint(PlasmaApp::defaultScreenSize());
        wp->setResizeMethodHint(Plasma::Wallpaper::ScaledAndCroppedResize);
    }

    m_model = new BackgroundListModel(wp, this);
    connect(m_model, SIGNAL(countChanged()), this, SLOT(modelCountChanged()));
    m_model->reload();

    if (engine()) {
        QDeclarativeContext *ctxt = engine()->rootContext();

        if (ctxt) {
            ctxt->setContextProperty("configInterface", this);
        }

        setQmlPath(m_package->filePath("mainscript"));
        m_mainWidget = qobject_cast<QDeclarativeItem *>(rootObject());

        if (m_mainWidget) {
            connect(m_mainWidget, SIGNAL(closeRequested()),
                    this, SLOT(deleteLater()));
        }
    }


    emit modelChanged();
}

ActivityConfiguration::~ActivityConfiguration()
{
}

void ActivityConfiguration::ensureContainmentExistence()
{
    if (m_containment) {
        return;
    }

#ifndef NO_ACTIVITIES
    const QString id = m_activityController->addActivity(m_activityName);
    m_activityController->setCurrentActivity(id);
#endif
    Plasma::Corona *corona = qobject_cast<Plasma::Corona *>(scene());
    QEventLoop loop;
    //FIXME: find a better way
    // AJS: a better way would be to connect the new containment signal in Corona
    QTimer::singleShot(100, &loop, SLOT(quit()));
    loop.exec();

    if (corona) {
        setContainment(corona->containmentForScreen(0));
    }
}

void ActivityConfiguration::setContainment(Plasma::Containment *cont)
{
    m_containment = cont;

    if (!m_containment) {
        // we are being setup for containment creation!
        m_newContainment = true;
    }

    if (m_containment) {
        m_activityName = m_containment->activity();
        emit activityNameChanged();
    }

    if (m_newContainment) {
        // reset this for the next time this dialog is used
        m_newContainment = false;
    }

    if (!m_containment) {
        return;
    }

    ensureContainmentHasWallpaperPlugin();
    m_model->setTargetSizeHint(m_containment->size().toSize());

    // save the wallpaper config so we can find the proper index later in modelCountChanged
    Plasma::Wallpaper *wp = m_containment->wallpaper();
    if (wp) {
        // shoulw always be true:
        // can only be false on a broken system with no wallpapers able to show images
        KConfigGroup wpConfig = wallpaperConfig();
        if (wpConfig.isValid()) {
            wp->save(wpConfig);
        }
    }
}

KConfigGroup ActivityConfiguration::wallpaperConfig()
{
    if (!m_containment || !m_containment->wallpaper()) {
        return KConfigGroup();
    }

    KConfigGroup wpConfig = m_containment->config();
    wpConfig = KConfigGroup(&wpConfig, "Wallpaper");
    wpConfig = KConfigGroup(&wpConfig, m_containment->wallpaper()->pluginName());
    return wpConfig;
}

void ActivityConfiguration::modelCountChanged()
{
    if (!m_containment || m_model->count() < 1) {
        return;
    }

    // since we're using the Image plugin, we'll cheat a bit and peek at the configuration
    // to see what wallpaper we're using
    QModelIndex index = m_model->indexOf(wallpaperConfig().readEntry("wallpaper", QString()));
    if (index.isValid()) {
        m_wallpaperIndex = index.row();
        emit wallpaperIndexChanged();
    }
}

Plasma::Containment *ActivityConfiguration::containment() const
{
    return m_containment;
}

void ActivityConfiguration::setActivityName(const QString &name)
{
    if (name == m_activityName) {
        return;
    }

    m_activityName = name;

    ensureContainmentExistence();
    if (!m_containment) {
        //should never happen
        return;
    }

    m_containment->setActivity(name);
    emit activityNameChanged();
}

QString ActivityConfiguration::activityName() const
{
    return m_activityName;
}

QString ActivityConfiguration::activityId() const
{
    if (!m_containment) {
        return QString();
    }

    return m_containment->context()->currentActivityId();
}

bool ActivityConfiguration::isActivityNameConfigurable() const
{
#ifndef NO_ACTIVITIES
    return true;
#else
    return false;
#endif
}

QObject *ActivityConfiguration::wallpaperModel()
{
    return m_model;
}

int ActivityConfiguration::wallpaperIndex()
{
    return m_wallpaperIndex;
}

void ActivityConfiguration::setWallpaperIndex(const int index)
{
    ensureContainmentExistence();
    if (!m_containment || !m_model) {
        //should never happen
        return;
    }

    if (m_wallpaperIndex == index || index < 0) {
        return;
    }

    m_wallpaperIndex = index;
    Plasma::Package *b = m_model->package(index);
    if (!b) {
        return;
    }

    QString wallpaper;
    if (b->structure()->contentsPrefixPaths().isEmpty()) {
        // it's not a full package, but a single paper
        wallpaper = b->filePath("preferred");
    } else {
        wallpaper = b->path();
    }

    kDebug()<<"Setting new wallpaper path:"<<wallpaper;

    if (!m_containment->wallpaper()) {
        const QString mimetype = KMimeType::findByUrl(wallpaper).data()->name();
        ensureContainmentHasWallpaperPlugin(mimetype);
    }

    if (m_containment->wallpaper()) {
        m_containment->wallpaper()->setUrls(KUrl::List() << wallpaper);
        KConfigGroup wpConfig = wallpaperConfig();
        if (wpConfig.isValid()) {
            wpConfig.writeEntry("wallpaper", wallpaper);
            //m_containment->wallpaper()->save(wpConfig);
        }

        emit containmentWallpaperChanged(m_containment);
    }

    emit wallpaperIndexChanged();
}

QString ActivityConfiguration::bestWallpaperPluginAvailable(const QString &mimetype) const
{
    const KPluginInfo::List wallpaperList = Plasma::Wallpaper::listWallpaperInfoForMimetype(mimetype);
    if (wallpaperList.isEmpty()) {
        // this would be a rather broken system
        return QString();
    }

    // we look for the image plugin, as that's really the one we want to default to
    foreach (const KPluginInfo &wallpaper, wallpaperList) {
        if (wallpaper.pluginName() == "image") {
            return "image";
        }
    }

    // "image" doesn't exist, so we just return whatever was first in the list
    return wallpaperList.at(0).name();
}

void ActivityConfiguration::ensureContainmentHasWallpaperPlugin(const QString &mimetype)
{
    if (m_containment && (!m_containment->wallpaper() || !m_containment->wallpaper()->supportsMimetype(mimetype))) {
        m_containment->setWallpaper(bestWallpaperPluginAvailable());
    }
}

QSize ActivityConfiguration::screenshotSize()
{
    return m_model ? m_model->screenshotSize() : QSize(320, 280);
}

void ActivityConfiguration::setScreenshotSize(const QSize &size)
{
    if (m_model) {
        m_model->setScreenshotSize(size);
    }
}

#include "activityconfiguration.moc"
