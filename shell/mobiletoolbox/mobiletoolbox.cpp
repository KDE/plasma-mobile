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

#include "mobiletoolbox.h"

#include <QGraphicsLinearLayout>
#include <QAction>

#include <KIconLoader>

#include <Plasma/Containment>
#include <Plasma/IconWidget>


MobileToolBox::MobileToolBox(Plasma::Containment *parent)
   : Plasma::AbstractToolBox(parent)
{
    init();
}

MobileToolBox::MobileToolBox(QObject *parent, const QVariantList &args)
    : AbstractToolBox(parent, args)
{
    init();
}

MobileToolBox::~MobileToolBox()
{
}

void MobileToolBox::init()
{
    m_containment = containment();
    Q_ASSERT(m_containment);

    setZValue(9000);

    m_layout = new QGraphicsLinearLayout(Qt::Vertical, this);

   QGraphicsItem *item = m_containment->property("toolBoxContainer").value<QGraphicsItem *>();

    if (item) {
        setParentItem(item);
    } else {
        hide();
    }
}

bool MobileToolBox::isShowing() const
{
    return true;
}

void MobileToolBox::setShowing(const bool show)
{
    Q_UNUSED(show);
}


void MobileToolBox::addTool(QAction *action)
{
    Plasma::IconWidget *button = new Plasma::IconWidget(this);
    button->setTextBackgroundColor(QColor());
    button->setAction(action);
    button->setText(QString());

    if (action == m_containment->action("add widgets")) {
        button->setSvg("widgets/action-overlays", "add-normal");
    }

    button->setContentsMargins(20, 20, 20, 20);
    button->setMinimumIconSize(QSizeF(48, 48));

    m_layout->addItem(button);
    m_actionButtons[action] = button;
}

void MobileToolBox::removeTool(QAction *action)
{
    if (m_actionButtons.contains(action)) {
        Plasma::IconWidget *button = m_actionButtons.value(action);
        m_layout->removeItem(button);
        m_actionButtons.remove(action);
        button->deleteLater();
    }
}


#include "mobiletoolbox.moc"
