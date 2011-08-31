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

#ifndef MOBILETOOLBOX_H
#define MOBILETOOLBOX_H

#include <QGraphicsWidget>
#include <QPropertyAnimation>
#include <KIcon>

#include <plasma/abstracttoolbox.h>
#include <plasma/containment.h>


class QGraphicsLinearLayout;

namespace Plasma
{
    class Containment;
    class IconWidget;
    class Svg;
}

class ToolContainer;

class MobileToolBox : public Plasma::AbstractToolBox
{
    Q_OBJECT
    Q_PROPERTY(bool showing READ isShowing WRITE setShowing )
public:
    explicit MobileToolBox(Plasma::Containment *parent = 0);
    explicit MobileToolBox(QObject *parent, const QVariantList &args);
    ~MobileToolBox();

    bool isShowing() const;
    void setShowing(const bool show);

    /**
     * create a toolbox tool from the given action
     * @p action the action to associate the tool with
     */
    void addTool(QAction *action);
    /**
     * remove the tool associated with this action
     */
    void removeTool(QAction *action);

protected:
    void init();

private:
    bool m_showing;
    Plasma::Containment *m_containment;
    QGraphicsLinearLayout *m_layout;
    QHash<QAction *, Plasma::IconWidget *> m_actionButtons;
};

K_EXPORT_PLASMA_TOOLBOX(mobiletoolbox, MobileToolBox)

#endif
