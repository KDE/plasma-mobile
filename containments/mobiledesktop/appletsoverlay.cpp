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

#include "appletsoverlay.h"

#include <QGraphicsAnchorLayout>
#include <QGraphicsSceneMouseEvent>
#include <QPainter>
#include <QStyleOptionGraphicsItem>

#include <KIconLoader>

#include <Plasma/Applet>
#include <Plasma/IconWidget>

AppletsOverlay::AppletsOverlay(QGraphicsItem *parent)
    : QGraphicsWidget(parent)
{
    QGraphicsAnchorLayout *lay = new QGraphicsAnchorLayout(this);

    Plasma::IconWidget *backButton = new Plasma::IconWidget(this);
    backButton->setSvg("widgets/arrows", "left-arrow");
    backButton->setPreferredIconSize(QSize(KIconLoader::SizeLarge, KIconLoader::SizeLarge));
    connect(backButton, SIGNAL(clicked()), this, SIGNAL(closeRequested()));

    lay->addAnchor(backButton, Qt::AnchorVerticalCenter, lay, Qt::AnchorVerticalCenter);
    lay->addAnchor(backButton, Qt::AnchorLeft, lay, Qt::AnchorLeft);

    Plasma::IconWidget *configureButton = new Plasma::IconWidget(this);
    configureButton->setSvg("widgets/configuration-icons", "configure");
    configureButton->setPreferredIconSize(QSize(KIconLoader::SizeLarge, KIconLoader::SizeLarge));
    connect(configureButton, SIGNAL(clicked()), this, SLOT(configureApplet()));

    lay->addCornerAnchors(configureButton, Qt::TopLeftCorner, lay, Qt::TopLeftCorner);
}

AppletsOverlay::~AppletsOverlay()
{
}

void AppletsOverlay::setApplet(Plasma::Applet *applet)
{
    if (applet) {
        m_applet = applet;
    } else {
        m_applet.clear();
    }
}

Plasma::Applet *AppletsOverlay::applet()
{
    return m_applet.data();
}

void AppletsOverlay::configureApplet()
{
    if (m_applet) {
        m_applet.data()->showConfigurationInterface();
    }
}

void AppletsOverlay::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    event->accept();
}

void AppletsOverlay::mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
{
    event->accept();
    emit closeRequested();
}

void AppletsOverlay::paint(QPainter *painter,
                       const QStyleOptionGraphicsItem *option,
                       QWidget *widget)
{
    Q_UNUSED(widget)

    QColor color(0, 0, 0, 150);
    painter->fillRect(option->rect, color);
}

#include "appletsoverlay.moc"

