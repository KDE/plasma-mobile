/*
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
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

#include "videowidget.h"

#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QFrame>
#include <QToolButton>

#include <Phonon/MediaObject>
#include <Phonon/VideoWidget>
#include <Phonon/AudioOutput>

#include <KWindowSystem>
#include <Plasma/WindowEffects>

#include "ui_videowindow.h"
#include "playeradaptor.h"

class VideoWidget::Private: public Ui::VideoWindowBase {
public:
     Phonon::MediaObject * mediaObject;
     Phonon::AudioOutput * audioOutput;

     static VideoWidget * instance;
};

VideoWidget * VideoWidget::Private::instance = NULL;

VideoWidget * VideoWidget::self()
{
    if (!VideoWidget::Private::instance) {
        VideoWidget::Private::instance = new VideoWidget();
    }

    return VideoWidget::Private::instance;
}

VideoWidget::VideoWidget()
    : d(new Private())
{
    d->setupUi(this);

    new PlayerAdaptor(this);
    QDBusConnection::sessionBus().registerService("org.mpris.MediaPlayer2.activevideo");
    QDBusConnection::sessionBus().registerObject("/org/mpris/MediaPlayer2", this);

    d->mediaObject = new Phonon::MediaObject(this);

    // d->videoWidget = new Phonon::VideoWidget(this);
    d->audioOutput =new Phonon::AudioOutput(Phonon::VideoCategory, this);

    Phonon::createPath(d->mediaObject, d->videoWidget);
    Phonon::createPath(d->mediaObject, d->audioOutput);

    // d->mediaObject->setQueue(QList<QUrl>() << QUrl("file:///home/ivan/Downloads/PinkFloydMomentary.avi"));
    // d->mediaObject->play();

    d->buttonPlay->setIcon(QIcon::fromTheme("media-playback-start"));
    d->buttonPlay->setIconSize(QSize(64, 64));
    connect(d->buttonPlay, SIGNAL(clicked()),
            this, SLOT(Play()));

    d->buttonPause->setIcon(QIcon::fromTheme("media-playback-pause"));
    d->buttonPause->setIconSize(QSize(64, 64));
    connect(d->buttonPause, SIGNAL(clicked()),
            this, SLOT(Pause()));

    d->buttonStop->setIcon(QIcon::fromTheme("media-playback-stop"));
    d->buttonStop->setIconSize(QSize(64, 64));
    connect(d->buttonStop, SIGNAL(clicked()),
            this, SLOT(Stop()));

    d->buttonIcon->setIcon(QIcon::fromTheme("active-video-viewer"));
    d->buttonIcon->setIconSize(QSize(64, 64));

    connect(d->videoWidget, SIGNAL(clicked()),
            this, SLOT(toggleControls()));
}

VideoWidget::~VideoWidget()
{
    delete d;
}

void VideoWidget::toggleControls()
{
    d->panelControls->setVisible(!d->panelControls->isVisible());
}

void VideoWidget::OpenUri(const QString & uri)
{
    d->mediaObject->setCurrentSource(QUrl(uri));
    Play();
}

void VideoWidget::Pause()
{
    d->mediaObject->pause();
}

void VideoWidget::Play()
{
    if (!isVisible()) {
        show();

        if (KWindowSystem::compositingActive()) {
            Plasma::WindowEffects::slideWindow(this, Plasma::BottomEdge);
        }

    }

    d->mediaObject->play();
}

void VideoWidget::Stop()
{
    hide();
}

QString VideoWidget::PlaybackStatus() const
{
    return QString();
}

void VideoWidget::hideEvent(QHideEvent * event)
{
    d->mediaObject->pause();
}
