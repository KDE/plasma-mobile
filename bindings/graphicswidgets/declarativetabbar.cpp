/***************************************************************************
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


#include "declarativetabbar.h"

TabBarAttached::TabBarAttached(QObject *parent)
    : QObject(parent)
{
}

void TabBarAttached::setTabText(const QString &text)
{
    if (text == m_tabText)
        return;

    m_tabText = text;
    emit tabTextChanged(reinterpret_cast<DeclarativeTabBar*>(parent()), m_tabText);
}

QString TabBarAttached::tabText()const
{
    return m_tabText;
}

DeclarativeTabBar::DeclarativeTabBar(QObject *parent)
  : Plasma::TabBar(qobject_cast<QGraphicsWidget *>(parent))
{}

DeclarativeTabBar::~DeclarativeTabBar()
{}

void DeclarativeTabBar::updateTabText(QGraphicsLayoutItem *item, const QString &text)
{
    for (int i=0; i < count(); ++i) {
        if (item == tabAt(i)) {
            setTabText(i, text);
            break;
        }
    }
}

QHash<QGraphicsLayoutItem*, TabBarAttached*> DeclarativeTabBar::m_attachedProperties;

TabBarAttached *DeclarativeTabBar::qmlAttachedProperties(QObject *obj)
{
    // ### This is not allowed - you must attach to any object
    if (!qobject_cast<QGraphicsLayoutItem*>(obj)) {
        return 0;
    }

    TabBarAttached *attached = new TabBarAttached(obj);
    m_attachedProperties.insert(qobject_cast<QGraphicsLayoutItem*>(obj), attached);
    return attached;
}

#include "declarativetabbar.moc"