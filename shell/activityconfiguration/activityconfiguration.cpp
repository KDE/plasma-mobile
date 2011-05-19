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
#include "backgroundlistmodel.h"

//Qt
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeItem>

//KDE
#include <KDebug>
#include <KStandardDirs>

//Plasma
#include <Plasma/Containment>
#include <Plasma/Package>

ActivityConfiguration::ActivityConfiguration(QGraphicsWidget *parent)
    : Plasma::DeclarativeWidget(parent),
      m_containment(0),
      m_mainWidget(0),
      m_model(0)
{
    setQmlPath(KStandardDirs::locate("data", "plasma-mobile/activityconfiguration/view.qml"));

    if (engine()) {
        QDeclarativeContext *ctxt = engine()->rootContext();
        m_mainWidget = qobject_cast<QDeclarativeItem *>(rootObject());
        if (ctxt) {
            ctxt->setContextProperty("configInterface", this);
        }

        if (m_mainWidget) {
            connect(m_mainWidget, SIGNAL(closeRequested()),
                    this, SLOT(deleteLater()));
        }
    }

    
}

ActivityConfiguration::~ActivityConfiguration()
{
}

void ActivityConfiguration::setContainment(Plasma::Containment *cont)
{
    m_containment = cont;
    m_model = new BackgroundListModel(m_containment->wallpaper(), this);
    m_model->setResizeMethod(Plasma::Wallpaper::CenteredResize);
    m_model->setWallpaperSize(QSize(1024, 600));
    m_model->reload();
    emit modelChanged();
}

Plasma::Containment *ActivityConfiguration::containment() const
{
    return m_containment;
}

void ActivityConfiguration::setActivityName(const QString &name)
{
    if (!m_containment) {
        return;
    }

    m_containment->setActivity(name);
}

QString ActivityConfiguration::activityName() const
{
    if (!m_containment) {
        return QString();
    }

    return m_containment->activity();
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
    if (m_containment->wallpaper()) {
        m_containment->wallpaper()->setUrls(KUrl::List() << wallpaper);
    }
}

QSize ActivityConfiguration::screenshotSize()
{
    return m_model->screenshotSize();
}

void ActivityConfiguration::setScreenshotSize(const QSize &size)
{
    m_model->setScreenshotSize(size);
}

#include "activityconfiguration.moc"
