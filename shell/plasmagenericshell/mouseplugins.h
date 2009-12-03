/*
 *   Copyright (c) 2009 Chani Armitage <chani@kde.org>
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

#ifndef CONTEXTACTIONDIALOG_H
#define CONTEXTACTIONDIALOG_H

#include "ui_MousePlugins.h"

namespace Plasma {
    class Containment;
}

class KConfigDialog;
class MousePluginWidget;
//class MouseInputButton;

class MousePlugins : public QWidget
{
    Q_OBJECT
public:
    MousePlugins(Plasma::Containment *containment, KConfigDialog *parent);
    ~MousePlugins();

signals:
    void modified(bool isModified);

public slots:
    void addTrigger(const QString&, const QString &trigger);
    void configChanged(const QString &trigger);
    void configAccepted();
    void containmentPluginChanged(Plasma::Containment *c);

private slots:
    /**
     * reassign the plugin's trigger to be @p newTrigger
     */
    void setTrigger(const QString &oldTrigger, const QString &newTrigger);

private:

    Ui::MousePlugins m_ui;
    Plasma::Containment *m_containment;
    QHash<QString, MousePluginWidget*> m_plugins;
    QSet<QString> m_modifiedKeys;
//    MouseInputButton *m_addButton;
};

#endif

