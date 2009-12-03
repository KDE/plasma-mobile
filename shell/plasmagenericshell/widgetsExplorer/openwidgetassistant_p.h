/*
 *   Copyright (C) 2008 Aaron Seigo <aseigo@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library/Lesser General Public License
 *   version 2, or (at your option) any later version, as published by the
 *   Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library/Lesser General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef PLASMA_OPENWIDGETASSISTANT_P_H
#define PLASMA_OPENWIDGETASSISTANT_P_H

#include <KAssistantDialog>
#include <KService>

class KFileWidget;
class KListWidget;
class QListWidgetItem;

namespace Plasma
{

class OpenWidgetAssistant : public KAssistantDialog
{
    Q_OBJECT

public:
    enum {
        PackageStructureRole = Qt::UserRole + 1
    };

    OpenWidgetAssistant(QWidget *parent);

protected Q_SLOTS:
    void prepPage(KPageWidgetItem *current, KPageWidgetItem *before);
    void finished();
    void slotHelpClicked();
    void slotItemChanged();

private:
    KPageWidgetItem *m_typePage;
    KPageWidgetItem *m_filePage;
    KFileWidget *m_fileDialog;
    QWidget *m_filePageWidget;
    KListWidget *m_widgetTypeList;
    KService::Ptr m_packageStructureService;
};

} // Plasma namespace

#endif
