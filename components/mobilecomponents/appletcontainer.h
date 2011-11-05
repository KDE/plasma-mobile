/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef APPLETCONTAINER_H
#define APPLETCONTAINER_H

#include <QDeclarativeItem>

namespace Plasma {
    class Applet;
}

class AppletContainer : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(QGraphicsWidget *applet READ applet WRITE setApplet NOTIFY appletChanged)

    Q_PROPERTY(int minimumWidth READ minimumWidth NOTIFY minimumWidthChanged)
    Q_PROPERTY(int minimumHeight READ minimumHeight NOTIFY minimumHeightChanged)

    Q_PROPERTY(int preferredWidth READ preferredWidth NOTIFY preferredWidthChanged)
    Q_PROPERTY(int preferredHeight READ preferredHeight NOTIFY preferredHeightChanged)

    Q_PROPERTY(int maximumWidth READ maximumWidth NOTIFY maximumWidthChanged)
    Q_PROPERTY(int maximumHeight READ maximumHeight NOTIFY maximumHeightChanged)

    Q_PROPERTY(ItemStatus status READ status WRITE setStatus NOTIFY statusChanged)
    Q_ENUMS(ItemStatus)

public:
    enum ItemStatus {
        UnknownStatus = 0, /**< The status is unknown **/
        PassiveStatus = 1, /**< The Item is passive **/
        ActiveStatus = 2, /**< The Item is active **/
        NeedsAttentionStatus = 3, /**< The Item needs attention **/
        AcceptingInputStatus = 4 /**< The Item is accepting input **/
    };

    AppletContainer(QDeclarativeItem *parent = 0);
    ~AppletContainer();

    QGraphicsWidget *applet() const;
    void setApplet(QGraphicsWidget *applet);

    int minimumWidth() const;
    int minimumHeight() const;

    int preferredWidth() const;
    int preferredHeight() const;

    int maximumWidth() const;
    int maximumHeight() const;

    void setStatus(const ItemStatus status);
    ItemStatus status() const;

Q_SIGNALS:
    void appletChanged(QGraphicsWidget *applet);

    void minimumWidthChanged(int);
    void minimumHeightChanged(int);

    void preferredWidthChanged(int);
    void preferredHeightChanged(int);

    void maximumWidthChanged(int);
    void maximumHeightChanged(int);

    void statusChanged();


protected Q_SLOTS:
    void sizeHintChanged(Qt::SizeHint which);
    void afterWidthChanged();
    void afterHeightChanged();

private:
    QWeakPointer<Plasma::Applet>m_applet;
};

#endif
