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

#include <Plasma/Animation>
#include <Plasma/Applet>
#include <Plasma/IconWidget>
#include <Plasma/PushButton>

AppletsOverlay::AppletsOverlay(QGraphicsItem *parent)
    : QGraphicsWidget(parent)
{
    m_layout = new QGraphicsAnchorLayout(this);

    Plasma::IconWidget *backButton = new Plasma::IconWidget(this);
    backButton->setSvg("widgets/arrows", "left-arrow");
    backButton->setPreferredIconSize(QSize(KIconLoader::SizeLarge, KIconLoader::SizeLarge));
    connect(backButton, SIGNAL(clicked()), this, SIGNAL(closeRequested()));

    m_layout->addAnchor(backButton, Qt::AnchorVerticalCenter, m_layout, Qt::AnchorVerticalCenter);
    m_layout->addAnchor(backButton, Qt::AnchorLeft, m_layout, Qt::AnchorLeft);


    Plasma::IconWidget *configureButton = new Plasma::IconWidget(this);
    configureButton->setSvg("widgets/configuration-icons", "configure");
    configureButton->setPreferredIconSize(QSize(KIconLoader::SizeLarge, KIconLoader::SizeLarge));
    connect(configureButton, SIGNAL(clicked()), this, SLOT(configureApplet()));

    m_layout->addCornerAnchors(configureButton, Qt::TopLeftCorner, m_layout, Qt::TopLeftCorner);


    m_askCloseButton = new Plasma::IconWidget(this);
    m_askCloseButton->setSvg("widgets/configuration-icons", "close");
    m_askCloseButton->setPreferredIconSize(QSize(KIconLoader::SizeLarge, KIconLoader::SizeLarge));
    connect(m_askCloseButton, SIGNAL(clicked()), this, SLOT(toggleDeleteButton()));

    m_layout->addCornerAnchors(m_askCloseButton, Qt::TopRightCorner, m_layout, Qt::TopRightCorner);
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

void AppletsOverlay::toggleDeleteButton()
{
    if (m_closeButton) {
        Plasma::Animation *anim = Plasma::Animator::create(Plasma::Animator::ZoomAnimation);
        anim->setTargetWidget(m_closeButton.data());
        anim->start(QAbstractAnimation::DeleteWhenStopped);
        connect(anim, SIGNAL(destroyed()), m_closeButton.data(), SLOT(deleteLater()));
    } else {
        m_closeButton = new Plasma::PushButton(this);
        m_closeButton.data()->setText(i18n("Delete?"));
        m_layout->addAnchor(m_closeButton.data(), Qt::AnchorVerticalCenter, m_askCloseButton, Qt::AnchorVerticalCenter);
        m_layout->addAnchor(m_closeButton.data(), Qt::AnchorRight, m_askCloseButton, Qt::AnchorLeft);
        Plasma::Animation *anim = Plasma::Animator::create(Plasma::Animator::ZoomAnimation);
        anim->setTargetWidget(m_closeButton.data());
        anim->setDirection(QAbstractAnimation::Backward);
        anim->start(QAbstractAnimation::DeleteWhenStopped);
        connect(m_closeButton.data(), SIGNAL(clicked()), this, SLOT(closeApplet()));
    }
}

void AppletsOverlay::closeApplet()
{
    if (m_applet) {
        m_applet.data()->destroy();
    }
    emit closeRequested();
}

void AppletsOverlay::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    event->accept();
}

void AppletsOverlay::mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
{
    event->accept();
    if (m_closeButton) {
        toggleDeleteButton();
    }
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

