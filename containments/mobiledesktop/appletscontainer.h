/*********************************************************************/
/* Copyright 2010 by Marco Martin <mart@kde.org>                     */
/*                                                                   */
/* This program is free software; you can redistribute it and/or     */
/* modify it under the terms of the GNU General Public License       */
/* as published by the Free Software Foundation; either version 2    */
/* of the License, or (at your option) any later version.            */
/*                                                                   */
/* This program is distributed in the hope that it will be useful,   */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of    */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the     */
/* GNU General Public License for more details.                      */
/*                                                                   */
/* You should have received a copy of the GNU General Public License */
/* along with this program; if not, write to the Free Software       */
/* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA     */
/* 02110-1301, USA.                                                  */
/*********************************************************************/

#ifndef APPLETSCONTAINER_H
#define APPLETSCONTAINER_H

#include <QGraphicsWidget>

namespace Plasma
{
    class Applet;
    class Containment;
}

class QGraphicsLinearLayout;
class QTimer;

class AppletsOverlay;

class AppletsContainer : public QGraphicsWidget
{
    Q_OBJECT
    friend class AppletsView;

public:
    AppletsContainer(QGraphicsItem *parent, Plasma::Containment *containment);
    ~AppletsContainer();

    void setCurrentApplet(Plasma::Applet *applet);
    Plasma::Applet *currentApplet() const;

    void setAppletsOverlayVisible(const bool visible);
    bool isAppletsOverlayVisible() const;

public Q_SLOTS:
    void layoutApplet(Plasma::Applet *applet, const QPointF &post);
    void hideAppletsOverlay();

protected:
    void syncOverlayGeometry();

    //reimp
    void resizeEvent(QGraphicsSceneResizeEvent *event);

protected Q_SLOTS:
    void relayout();

private:
    QGraphicsLinearLayout *m_layout;
    Plasma::Containment *m_containment;
    QTimer *m_relayoutTimer;
    QWeakPointer<Plasma::Applet> m_currentApplet;
    AppletsOverlay *m_appletsOverlay;
};

#endif
