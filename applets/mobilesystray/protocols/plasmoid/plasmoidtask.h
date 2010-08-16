/***************************************************************************
 *   plasmoidtask.h                                                        *
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

#ifndef PLASMOIDTASK_H
#define PLASMOIDTASK_H

#include "../../core/task.h"

#include <plasma/plasma.h>

namespace SystemTray
{


class PlasmoidTask : public Task
{
    Q_OBJECT

public:
// removed as we should not need to add applet by name anymore.
//    PlasmoidTask(const QString &appletName, int id, QObject *parent, Plasma::Applet *host);
    PlasmoidTask(Plasma::Applet* applet, int id, QObject *parent, Plasma::Applet *host);
    virtual ~PlasmoidTask();

    bool isValid() const;
    virtual bool isEmbeddable() const;
    virtual QString name() const;
    virtual QString typeId() const;
    virtual QIcon icon() const;
    void forwardConstraintsEvent(Plasma::Constraints constraints);
    Plasma::Applet *host() const;

protected Q_SLOTS:
    void appletDestroyed(QObject *object);
    void newAppletStatus(Plasma::ItemStatus status);

Q_SIGNALS:
    void taskDeleted(Plasma::Applet *host, const QString &typeId);

protected:
    virtual QGraphicsWidget* createWidget(Plasma::Applet *applet);

private:
    void setupApplet(Plasma::Applet *applet, int id);

    QString m_name;
    QString m_typeId;
    QIcon m_icon;
    QWeakPointer<Plasma::Applet> m_applet;
    Plasma::Applet *m_host;
    bool m_takenByParent;
};

}

#endif
