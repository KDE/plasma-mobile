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


#ifndef DECLARATIVETABBAR
#define DECLARATIVETABBAR

#include <QtDeclarative/qdeclarative.h>
#include <QDeclarativeListProperty>

#include "plasma/widgets/tabbar.h"

class TabBarAttached : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString tabText READ tabText WRITE setTabText NOTIFY tabTextChanged)

public:
    TabBarAttached(QObject *parent);

    void setTabText(const QString& text);
    QString tabText() const;

Q_SIGNALS:
    void tabTextChanged(QGraphicsLayoutItem*, const QString&);

private:
    QString m_tabText;
};

class DeclarativeTabBar : public Plasma::TabBar
{
    Q_OBJECT

    Q_PROPERTY(KTabBar *nativeWidget READ nativeWidget)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex)
    Q_PROPERTY(int count READ count)
    Q_PROPERTY(QString styleSheet READ styleSheet WRITE setStyleSheet)
    Q_PROPERTY(bool tabBarShown READ isTabBarShown WRITE setTabBarShown)

    Q_PROPERTY(QDeclarativeListProperty<QGraphicsLayoutItem> children READ children)
    Q_CLASSINFO("DefaultProperty", "children")

public:
    DeclarativeTabBar(QObject *parent = 0);
    ~DeclarativeTabBar();

    QDeclarativeListProperty<QGraphicsLayoutItem> children() { return QDeclarativeListProperty<QGraphicsLayoutItem>(this, 0, children_append, children_count, children_at, children_clear); }

    static TabBarAttached *qmlAttachedProperties(QObject *);

private Q_SLOTS:
    void updateTabText(QGraphicsLayoutItem *, const QString&);

private:
    static QHash<QGraphicsLayoutItem*, TabBarAttached*> m_attachedProperties;

    static void children_append(QDeclarativeListProperty<QGraphicsLayoutItem> *prop, QGraphicsLayoutItem *item) {
        QString text;
        DeclarativeTabBar *tabBar = static_cast<DeclarativeTabBar*>(prop->object);
        if (TabBarAttached *obj = m_attachedProperties.value(item)) {
            text = obj->tabText();
            QObject::connect(obj, SIGNAL(tabTextChanged(QGraphicsLayoutItem*,int)),
                             tabBar, SLOT(updateTabText(QGraphicsLayoutItem*,int)));
        }
        tabBar->addTab(text, item);
    }

    static void children_clear(QDeclarativeListProperty<QGraphicsLayoutItem> *prop) {
        DeclarativeTabBar *tabBar = static_cast<DeclarativeTabBar*>(prop->object);
        for (int i=0; i < tabBar->count(); ++i) {
            tabBar->removeTab(0);
        }
    }

    static int children_count(QDeclarativeListProperty<QGraphicsLayoutItem> *prop) {
        return static_cast<DeclarativeTabBar*>(prop->object)->count();
    }

    static QGraphicsLayoutItem *children_at(QDeclarativeListProperty<QGraphicsLayoutItem> *prop, int index) {
        return static_cast<DeclarativeTabBar*>(prop->object)->tabAt(index);
    }
};

QML_DECLARE_TYPE(DeclarativeTabBar)
QML_DECLARE_TYPEINFO(DeclarativeTabBar, QML_HAS_ATTACHED_PROPERTIES)

#endif
