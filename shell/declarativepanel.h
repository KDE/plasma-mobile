/***************************************************************************
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
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
#ifndef PANEL_PROXY_P
#define PANEL_PROXY_P

#include <QObject>
#include <QWeakPointer>
#include <QPoint>

class QGraphicsObject;
class QGraphicsView;


class PanelProxy : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QGraphicsObject *mainItem READ mainItem WRITE setMainItem NOTIFY mainItemChanged)
    Q_PROPERTY(bool visible READ isVisible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(int x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(int y READ y WRITE setY NOTIFY yChanged)

public:
    enum WidgetAttribute {
        WA_X11NetWmWindowTypeDock = Qt::WA_X11NetWmWindowTypeDock
    };

    PanelProxy(QObject *parent = 0);
    ~PanelProxy();

    QGraphicsObject *mainItem() const;
    void setMainItem(QGraphicsObject *mainItem);

    bool isVisible() const;
    void setVisible(const bool visible);

    int x() const;
    void setX(int x);

    int y() const;
    void setY(int y);


Q_SIGNALS:
    void mainItemChanged();
    void visibleChanged();
    void xChanged();
    void yChanged();

protected Q_SLOTS:
    void syncMainItem();

protected:
    bool eventFilter(QObject *watched, QEvent *event);

private:
    QGraphicsView *m_panel;
    QWeakPointer<QGraphicsObject> m_mainItem;
    static uint s_numItems;
};

#endif
