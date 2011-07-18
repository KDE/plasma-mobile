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
#include <QTimer>
#include <QGraphicsView>
#include <QApplication>

//KDE
#include <KDebug>
#include <KStandardDirs>

//Plasma
#include <Plasma/Containment>
#include <Plasma/Corona>
#include <Plasma/Context>
#include <Plasma/Package>

#include <Activities/Controller>

ActivityConfiguration::ActivityConfiguration(QGraphicsWidget *parent)
    : Plasma::DeclarativeWidget(parent),
      m_containment(0),
      m_mainWidget(0),
      m_model(0),
      m_firstConfig(false)
{
    setQmlPath(KStandardDirs::locate("data", "plasma-mobile/activityconfiguration/view.qml"));
    m_activityController = new Activities::Controller(this);

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

void ActivityConfiguration::ensureContainmentExistence()
{
    if (m_containment) {
        return;
    }

    const QString id = m_activityController->addActivity(m_activityName);
    m_activityController->setCurrentActivity(id);
    Plasma::Corona *corona = qobject_cast<Plasma::Corona *>(scene());
    QEventLoop loop;
    //FIXME: find a better way
    QTimer::singleShot(100, &loop, SLOT(quit()));
    loop.exec();
    if (corona) {
        m_containment = corona->containmentForScreen(0);
    }
}

void ActivityConfiguration::setFirstConfig(bool firstConfig)
{
    if (m_firstConfig == firstConfig) {
        return;
    }

    m_firstConfig = firstConfig;

    //FIXME: this has to be done in C++ until we have QtComponents
    if (firstConfig) {
        QGraphicsWidget *activityNameEdit = m_mainWidget->findChild<QGraphicsWidget*>("activityNameEdit");
        if (activityNameEdit) {
            activityNameEdit->setFocus(Qt::MouseFocusReason);
            QEvent openEvent(QEvent::RequestSoftwareInputPanel);
            if (qApp) {
                if (QGraphicsView *view = qobject_cast<QGraphicsView*>(qApp->focusWidget())) {
                    if (view->scene() && view->scene() == scene()) {
                        QApplication::sendEvent(view, &openEvent);
                    }
                }
            }
        }
    }

    emit firstConfigChanged();
}

bool ActivityConfiguration::firstConfig() const
{
    return m_firstConfig;
}

void ActivityConfiguration::setContainment(Plasma::Containment *cont)
{
    m_containment = cont;

    delete m_model;

    Plasma::Wallpaper *wp = 0;
    if (m_containment && m_containment->wallpaper()) {
        wp = m_containment->wallpaper();
    } else {
        wp = Plasma::Wallpaper::load("image");
        wp->setParent(this);

        //FIXME: this has to be done in C++ until we have QtComponents
        //doesn't really belong here, this is for the "first run"
        QGraphicsWidget *activityNameEdit = m_mainWidget->findChild<QGraphicsWidget*>("activityNameEdit");
        if (activityNameEdit) {
            activityNameEdit->setFocus(Qt::MouseFocusReason);
            QEvent openEvent(QEvent::RequestSoftwareInputPanel);
            if (qApp) {
                if (QGraphicsView *view = qobject_cast<QGraphicsView*>(qApp->focusWidget())) {
                    if (view->scene() && view->scene() == scene()) {
                        QApplication::sendEvent(view, &openEvent);
                    }
                }
            }
        }
    }

    m_model = new BackgroundListModel(wp, this);
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
    if (name == m_activityName) {
        return;
    }

    m_activityName = name;

    if (!m_containment) {
        ensureContainmentExistence();
        //should never happen
        if (!m_containment) {
            return;
        }
    }

    m_containment->setActivity(name);
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
    if (!m_containment) {
        ensureContainmentExistence();
        //should never happen
        if (!m_containment) {
            return;
        }
    }

    if (!m_wallpaperIndex == index || index < 0) {
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
