/////////////////////////////////////////////////////////////////////////
// appletscontainer.cpp                                                //
//                                                                     //
// Copyright 2010 by Marco Martin <mart@kde.org>                       //
//                                                                     //
// This library is free software; you can redistribute it and/or       //
// modify it under the terms of the GNU Lesser General Public          //
// License as published by the Free Software Foundation; either        //
// version 2.1 of the License, or (at your option) any later version.  //
//                                                                     //
// This library is distributed in the hope that it will be useful,     //
// but WITHOUT ANY WARRANTY; without even the implied warranty of      //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU   //
// Lesser General Public License for more details.                     //
//                                                                     //
// You should have received a copy of the GNU Lesser General Public    //
// License along with this library; if not, write to the Free Software //
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA       //
// 02110-1301  USA                                                     //
/////////////////////////////////////////////////////////////////////////

#include "appletscontainer.h"
#include "appletsoverlay.h"

#include <cmath>

#include <QGraphicsLinearLayout>
#include <QGraphicsSceneResizeEvent>
#include <QTimer>
#include <QParallelAnimationGroup>

#include <KGlobalSettings>
#include <KIconLoader>

#include <Plasma/AbstractToolBox>
#include <Plasma/Animation>
#include <Plasma/Applet>
#include <Plasma/Containment>
#include <Plasma/IconWidget>

//on some devices it is too much
#define NO_ANIMATIONS

using namespace Plasma;

class InputBlocker : public QGraphicsWidget
{
public:
    InputBlocker(AppletsContainer *container)
        : QGraphicsWidget(container),
          m_container(container)
    {
        setFlag(QGraphicsItem::ItemHasNoContents);
    }

    ~InputBlocker()
    {}

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event)
    {
        event->accept();
    }

    void mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
    {
        if (QPointF(event->buttonDownScenePos(event->button()) - event->scenePos()).manhattanLength() < KGlobalSettings::dndEventDelay()*2) {
            foreach (Plasma::Applet *applet, m_container->containment()->applets()) {
                if (applet->boundingRect().contains(applet->mapFromScene(event->scenePos()))) {
                    m_container->setCurrentApplet(applet);
                    return;
                }
            }
        }
    }

private:
    AppletsContainer *m_container;
};

AppletsContainer::AppletsContainer(QGraphicsItem *parent, Plasma::Containment *containment)
 : QGraphicsWidget(parent),
   m_containment(containment),
   m_toolBox(0),
   m_appletsOverlay(0),
   m_startupCompleted(false),
   m_orientation(Qt::Horizontal)
{
    setFlag(QGraphicsItem::ItemHasNoContents);

    m_toolBox = Plasma::AbstractToolBox::load("org.kde.mobiletoolbox", QVariantList(), containment);
    m_toolBox->setParentItem(this);
    QAction *a = containment->action("add widgets");
    if (a) {
        m_toolBox->addTool(a);
    }

    m_inputBlocker = new InputBlocker(this);
    m_inputBlocker->setZValue(2000);
    m_toolBox->setZValue(2001);
    m_inputBlocker->show();

    m_relayoutTimer = new QTimer(this);
    m_relayoutTimer->setSingleShot(true);
    connect(m_relayoutTimer, SIGNAL(timeout()), this, SLOT(relayout()));
}

AppletsContainer::~AppletsContainer()
{
}

void AppletsContainer::setOrientation(const Qt::Orientation orientation)
{
    if (m_orientation == orientation) {
        return;
    }

    m_orientation = orientation;
    relayout();
}

Qt::Orientation AppletsContainer::orientation() const
{
    return m_orientation;
}

Plasma::Containment *AppletsContainer::containment() const
{
    return m_containment;
}

void AppletsContainer::completeStartup()
{
    m_startupCompleted = true;

    foreach (Plasma::Applet *applet, m_startingApplets) {
        m_applets.append(applet);
    }
    m_startingApplets.clear();

    relayout();
}

void AppletsContainer::layoutApplet(Plasma::Applet* applet, const QPointF &pos)
{
    applet->setParentItem(this);
    applet->setFlag(ItemIsMovable, false);
    applet->setZValue(0);
    relayoutApplet(applet, pos);
}

void AppletsContainer::relayoutApplet(Plasma::Applet *applet, const QPointF &pos)
{
    //FIXME: duplication and magic numbers --
    const int squareSize = 350;
    int columns = qMax(1, (int)m_containment->size().width() / squareSize);
    int rows = qMax(1, (int)m_containment->size().height() / squareSize);
    const QSizeF maximumAppletSize(m_containment->size().width()/columns, m_containment->size().height()/rows);

    int newIndex;
    if (pos == QPointF(-1, -1)) {
        newIndex = m_applets.count();
    } else {
        newIndex = rows * round(pos.y() / maximumAppletSize.height()) + round(pos.x() / maximumAppletSize.width()) - 1;
    }

    if (m_startupCompleted) {
        m_applets.removeAll(applet);
        m_applets.insert(newIndex, applet);

        relayout();
    } else {
        while (m_startingApplets.contains(newIndex)) {
            ++newIndex;
        }

        m_startingApplets[newIndex] = applet;
    }
}

void AppletsContainer::appletRemoved(Plasma::Applet *applet)
{
    m_applets.removeAll(applet);
    applet->setFlag(ItemIsMovable, true);
    relayout();
}

void AppletsContainer::relayout()
{
    if (m_applets.isEmpty()) {
        m_toolBox->setPos(0,0);
        return;
    }

    const int squareSize = 350;
    int columns = qMax(1, (int)m_containment->size().width() / squareSize);
    int rows = qMax(1, (int)m_containment->size().height() / squareSize);
    const QSizeF maximumAppletSize(m_containment->size().width()/columns, m_containment->size().height()/rows);

#ifndef NO_ANIMATIONS
    QParallelAnimationGroup *group = new QParallelAnimationGroup(this);
#endif

    int i = 0;
    foreach (Plasma::Applet *applet, m_applets) {
        if (applet == m_currentApplet.data()) {
            i++;
            continue;
        }
        applet->setZValue(0);
        QSizeF appletSize = applet->effectiveSizeHint(Qt::PreferredSize);
        appletSize = appletSize.boundedTo(maximumAppletSize - QSize(0, 70));
        appletSize = appletSize.expandedTo(QSize(250, 250));
        QSizeF offset(QSizeF(maximumAppletSize - appletSize)/2);

        QRectF targetGeom;
        if (m_orientation == Qt::Vertical) {
            if ((m_containment->applets().count() - i < columns) &&
                (i/columns == m_containment->applets().count()/columns) &&
                ((i+1)%columns != 0)) {
                offset.rwidth() += ((i+1)%columns * maximumAppletSize.width())/columns;
            }


            targetGeom = QRectF((i%columns)*maximumAppletSize.width() + offset.width(), (i/columns)*maximumAppletSize.height() + offset.height(), appletSize.width(), appletSize.height());
        } else {
            if ((m_containment->applets().count() - i < rows) &&
                (i/rows == m_containment->applets().count()/rows) &&
                ((i+1)%rows != 0)) {
                offset.rheight() += ((i+1)%rows * maximumAppletSize.height())/rows;
            }


            targetGeom = QRectF((i/rows)*maximumAppletSize.width() + offset.width(), (i%rows)*maximumAppletSize.height() + offset.height(), appletSize.width(), appletSize.height());
        }
#ifndef NO_ANIMATIONS
        Animation *anim = Plasma::Animator::create(Plasma::Animator::GeometryAnimation);
        anim->setTargetWidget(applet);
        anim->setProperty("startGeometry", applet->geometry());
        anim->setProperty("targetGeometry", targetGeom);
        group->addAnimation(anim);
#else
        applet->setGeometry(targetGeom);
#endif
        i++;
    }

    if (m_orientation == Qt::Vertical) {
        resize(size().width(),
            (ceil((qreal)m_containment->applets().count()/columns))
                * (maximumAppletSize.height() + (m_applets.count()%2==0?maximumAppletSize.height():0)));
    } else {
        resize((ceil((qreal)m_containment->applets().count()/rows))
                * (maximumAppletSize.width() + (m_applets.count()%2==0?maximumAppletSize.width():0)),
                size().height()
              );
    }

#ifndef NO_ANIMATIONS
    group->start(QAbstractAnimation::DeleteWhenStopped);
    connect(group, SIGNAL(finished()), this, SLOT(repositionToolBox()));
#else
    repositionToolBox();
#endif
}

void AppletsContainer::repositionToolBox()
{
    const int squareSize = 350;
    const int columns = qMax(1, (int)m_containment->size().width() / squareSize);
    const int rows = qMax(1, (int)m_containment->size().height() / squareSize);
    const QSizeF maximumAppletSize(m_containment->size().width()/columns, m_containment->size().height()/rows);


    if (m_toolBox) {
        int extraHeight = 0;
        QRectF buttonGeom = m_toolBox->geometry();

        if (m_orientation == Qt::Vertical) {
            if (m_applets.count() % columns != 0) {
                QRectF geom = m_applets.last()->geometry();
                geom = QRectF(geom.topRight(),
                            QSizeF(size().width() - geom.right(), geom.height()));

                buttonGeom.moveCenter(geom.center());
            } else {
                QRectF geom(QPointF(0, maximumAppletSize.height() * (m_applets.count() / columns)), 
                            QSizeF(size().width(), maximumAppletSize.height()));

                buttonGeom.moveCenter(geom.center());
                extraHeight = maximumAppletSize.height();
            }

            m_toolBox->setPos(buttonGeom.topLeft());

            resize(size().width(), (ceil((qreal)m_containment->applets().count()/columns))*maximumAppletSize.height() + extraHeight);
        } else {
            int extraWidth = 0;
            if (m_applets.count() % rows != 0) {
                QRectF geom = m_applets.last()->geometry();
                geom = QRectF(geom.bottomLeft(),
                            QSizeF(geom.width(), size().height() - geom.bottom()));

                buttonGeom.moveCenter(geom.center());
            } else {
                QRectF geom(QPointF(maximumAppletSize.width() * (m_applets.count() / rows), 0),
                            QSizeF(maximumAppletSize.width(), size().height()));

                buttonGeom.moveCenter(geom.center());
                extraWidth = maximumAppletSize.width();
            }

            m_toolBox->setPos(buttonGeom.topLeft());

            resize((ceil((qreal)m_containment->applets().count()/rows))*maximumAppletSize.width() + extraWidth,
                   size().height());
        }
    }

    m_relayoutTimer->stop();
}

void AppletsContainer::resizeEvent(QGraphicsSceneResizeEvent *event)
{
    if (((m_orientation == Qt::Vertical && !qFuzzyCompare(event->oldSize().width(), event->newSize().width())) ||
         (m_orientation == Qt::Horizontal && !qFuzzyCompare(event->oldSize().height(), event->newSize().height())))
        && !m_relayoutTimer->isActive()) {
        m_relayoutTimer->start(300);
    }

    m_inputBlocker->resize(event->newSize());

    syncOverlayGeometry();
}

void AppletsContainer::setAppletsOverlayVisible(const bool visible)
{
    if (visible) {
        if (!m_appletsOverlay) {
            m_appletsOverlay = new AppletsOverlay(this);
            connect(m_appletsOverlay, SIGNAL(closeRequested()), this, SLOT(hideAppletsOverlay()));
        }

        syncOverlayGeometry();
        m_appletsOverlay->setZValue(2100);
    }

    m_appletsOverlay->setVisible(visible);
}

bool AppletsContainer::isAppletsOverlayVisible() const
{
    return m_appletsOverlay && m_appletsOverlay->isVisible();
}

void AppletsContainer::hideAppletsOverlay()
{
    setAppletsOverlayVisible(false);
    setCurrentApplet(0);
}


void AppletsContainer::setCurrentApplet(Plasma::Applet *applet)
{
    if (m_currentApplet.data() == applet) {
        return;
    }


    if (m_currentApplet) {
        m_currentApplet.data()->lower();
    }

    m_currentApplet = applet;

    //FIXME: can be done more efficiently
    relayout();

    if (applet) {
        applet->setFlag(ItemIsMovable, false);
        setAppletsOverlayVisible(true);
        m_appletsOverlay->setApplet(applet);
        m_currentApplet.data()->raise();
        m_currentApplet.data()->setZValue(qMax(applet->zValue(), (qreal)2200));
        m_appletsOverlay->setZValue(qMax(applet->zValue()-1, (qreal)2100));
        syncOverlayGeometry();
    } else {
        setAppletsOverlayVisible(false);
        if (m_appletsOverlay) {
            m_appletsOverlay->setApplet(0);
        }
    }

}

Plasma::Applet *AppletsContainer::currentApplet() const
{
    return m_currentApplet.data();
}

void AppletsContainer::syncOverlayGeometry()
{
    if (m_currentApplet) {
        const int margin = KIconLoader::SizeHuge;

        QRectF targetGeom(mapFromItem(m_containment, m_containment->boundingRect()).boundingRect().adjusted(margin, margin/2, -margin, -margin/2));
#ifndef NO_ANIMATIONS
        Animation *anim = Plasma::Animator::create(Plasma::Animator::GeometryAnimation);
        anim->setTargetWidget(m_currentApplet.data());
        anim->setProperty("startGeometry", m_currentApplet.data()->geometry());
        anim->setProperty("targetGeometry", targetGeom);
        anim->start(QAbstractAnimation::DeleteWhenStopped);
#else
        m_currentApplet.data()->setGeometry(targetGeom);
#endif
    }

    if (m_appletsOverlay) {
        m_appletsOverlay->setGeometry(mapFromItem(m_containment, m_containment->boundingRect()).boundingRect());
    }
}

#include "appletscontainer.moc"

