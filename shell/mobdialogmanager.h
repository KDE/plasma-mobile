/*
 *   Copyright (C) 2010 Marco Martin <notmart@gmail.com>
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

#ifndef MOB_DIALOGMANAGER_H
#define MOB_DIALOGMANAGER_H

#include <plasma/abstractdialogmanager.h>

#include <QtCore/QHash>


namespace Plasma
{
    class Corona;
}

class MobDialogManager : public Plasma::AbstractDialogManager
{
    Q_OBJECT

public:
    explicit MobDialogManager(Plasma::Corona *parent=0);
    ~MobDialogManager();

public Q_SLOTS:
    void showDialog(QWidget *widget, Plasma::Applet *applet);

private:
    Plasma::Corona *m_corona;
};

#endif
