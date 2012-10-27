/***************************************************************************
 *   Copyright 2010 MArco Martin <mart@kde.org>                            *
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

#ifndef PLASMA_MOBILEWIDGETEXPLORER_H
#define PLASMA_MOBILEWIDGETEXPLORER_H

#include <QGraphicsWidget>

class QDeclarativeItem;

class PlasmaAppletItemModel;

namespace Plasma
{
    class Containment;
    class DeclarativeWidget;
    class Package;
}

class MobileWidgetsExplorer : public QGraphicsWidget
{
    Q_OBJECT

public:
    MobileWidgetsExplorer(const QString &uiPackage = "org.kde.active.addresources", QGraphicsItem *parent = 0);
    ~MobileWidgetsExplorer();

    void setContainment(Plasma::Containment *cont);
    Plasma::Containment *containment() const;

protected Q_SLOTS:
    void addApplet(const QString &plugin);
    void doExit();

private:
    Plasma::Containment *m_containment;
    QDeclarativeItem *m_mainWidget;
    Plasma::DeclarativeWidget *m_declarativeWidget;
    Plasma::Package *m_package;

    PlasmaAppletItemModel *m_appletsModel;
};

#endif //PLASMA_MOBILEWIDGETEXPLORER_H
