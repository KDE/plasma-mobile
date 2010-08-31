/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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

#ifndef PLASMA_MOBILEDESKTOP_H
#define PLASMA_MOBILEDESKTOP_H

#include <Plasma/Containment>

namespace Plasma
{
    class ScrollWidget;
}

class AppletsContainer;
class AppletsView;

class MobileDesktop : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(QGraphicsItem *toolBoxContainer READ toolBoxContainer)

public:
    MobileDesktop(QObject *parent, const QVariantList &args);
    ~MobileDesktop();
    void init();

    void constraintsEvent(Plasma::Constraints constraints);

    QGraphicsItem *toolBoxContainer() const;

protected:
    void dragEnterEvent(QGraphicsSceneDragDropEvent *event);
    void dragLeaveEvent(QGraphicsSceneDragDropEvent *event);
    void dragMoveEvent(QGraphicsSceneDragDropEvent *event);
    void dropEvent(QGraphicsSceneDragDropEvent *event);

private:
    AppletsContainer *m_container;
    AppletsView *m_appletsView;
};

#endif // PLASMA_DESKTOP_H
