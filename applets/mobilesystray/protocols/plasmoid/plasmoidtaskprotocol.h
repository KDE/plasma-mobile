/***************************************************************************
 *   plasmoidprotocol.h                                                    *
 *                                                                         *
 *   Copyright (C) 2008 Jason Stubbs <jasonbstubbs@gmail.com>              *
 *   Copyright (C) 2008 Sebastian Kügler <sebas@kde.org>                   *
 *   Copyright (C) 2009 Marco Martin <notmart@gmail.com>                   *
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

#ifndef PLASMOIDTASKPROTOCOL_H
#define PLASMOIDTASKPROTOCOL_H

#include "../../core/protocol.h"

#include <KConfigGroup>

#include <QHash>
#include <QStringList>

namespace SystemTray
{

class PlasmoidTask;

class PlasmoidProtocol : public Protocol
{
    Q_OBJECT

public:
    PlasmoidProtocol(QObject * parent);
    ~PlasmoidProtocol();

    void init();

    void forwardConstraintsEvent(Plasma::Constraints constraints, Plasma::Applet *host);
    void loadFromConfig(Plasma::Applet *parent);
    void addApplet(const QString appletName, const int id, Plasma::Applet *parent);
    void removeApplet(const QString appletName, Plasma::Applet *parent);
    QStringList applets(Plasma::Applet *parent) const;

private slots:
    void cleanupTask(Plasma::Applet *host, const QString &typeId);

private:
    QHash<Plasma::Applet *, QHash<QString, PlasmoidTask*> > m_tasks;
};

}


#endif
