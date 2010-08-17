/*
 *   Copyright 2010 Marco Martin <mart@kde.org>
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

#include "dragcountdown.h"

#include <QColor>
#include <QPainter>
#include <QStyleOptionGraphicsItem>
#include <QTimer>

#include <KDebug>
#include <KIconLoader>

#include <Plasma/Svg>
#include <Plasma/Theme>

DragCountdown::DragCountdown(QGraphicsItem *parent)
    : QGraphicsWidget(parent),
      m_progress(0),
      m_increment(0)
{
    hide();
    setFlag(QGraphicsItem::ItemHasNoContents, false);
    m_animationTimer = new QTimer(this);

    m_countdownTimer = new QTimer(this);
    m_countdownTimer->setSingleShot(true);
    connect(m_countdownTimer, SIGNAL(timeout()), this, SIGNAL(dragRequested()));

    m_animationTimer = new QTimer(this);
    m_animationTimer->setSingleShot(false);
    connect(m_animationTimer, SIGNAL(timeout()), this, SLOT(updateProgress()));

    resize(KIconLoader::SizeLarge, KIconLoader::SizeLarge);

    m_icons = new Plasma::Svg(this);
    m_icons->setImagePath("widgets/configuration-icons");
    m_icons->setContainsMultipleImages(true);
}

DragCountdown::~DragCountdown()
{
}

void DragCountdown::start(const int timeout)
{
    m_progress = 0;
    if (timeout > 0) {
        m_increment = (qreal)40/timeout;
        m_animationTimer->start(40);
    } else {
        emit dragRequested();
    }
    show();
}

void DragCountdown::stop()
{
    m_animationTimer->stop();
    hide();
}

void DragCountdown::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    painter->save();

    painter->setRenderHint(QPainter::Antialiasing);
    QColor color(Plasma::Theme::defaultTheme()->color(Plasma::Theme::TextColor));
    color.setAlphaF(0.6);
    painter->setPen(QPen(color, 4));

    if (m_animationTimer->isActive()) {
        painter->drawArc(boundingRect(), 0, m_progress * 360 * 16);
    } else {
        m_icons->paint(painter, boundingRect(), "move");
    }

    painter->restore();
}

void DragCountdown::updateProgress()
{
    m_progress += m_increment;
    if (m_progress >= 1) {
        m_animationTimer->stop();
        m_progress = 0;
        emit dragRequested();
    }
    update();
}

#include "dragcountdown.moc"
