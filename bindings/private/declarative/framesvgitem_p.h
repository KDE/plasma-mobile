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
#ifndef FRAMESVGITEM_P
#define FRAMESVGITEM_P

#include <QDeclarativeItem>

namespace Plasma {

    class FrameSvg;

class FrameSvgItemMargins : public QObject
{
    Q_OBJECT

    Q_PROPERTY(qreal left READ left NOTIFY marginsChanged)
    Q_PROPERTY(qreal top READ top NOTIFY marginsChanged)
    Q_PROPERTY(qreal right READ right NOTIFY marginsChanged)
    Q_PROPERTY(qreal bottom READ bottom NOTIFY marginsChanged)

public:
    FrameSvgItemMargins(Plasma::FrameSvg *frameSvg, QObject *parent = 0);

    qreal left() const;
    qreal top() const;
    qreal right() const;
    qreal bottom() const;

Q_SIGNALS:
    void marginsChanged();

private:
    FrameSvg *m_frameSvg;
};

class FrameSvgItem : public QDeclarativeItem
{
    Q_OBJECT

    Q_PROPERTY(QString imagePath READ imagePath WRITE setImagePath)
    Q_PROPERTY(QString prefix READ prefix WRITE setPrefix)
    Q_PROPERTY(QObject *margins READ margins CONSTANT)

public:
    FrameSvgItem(QDeclarativeItem *parent=0);
    ~FrameSvgItem();

    void setImagePath(const QString &path);
    QString imagePath() const;

    void setPrefix(const QString &prefix);
    QString prefix() const;

    FrameSvgItemMargins *margins() const;

    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget);

    void geometryChanged(const QRectF &newGeometry,
                              const QRectF &oldGeometry);

private Q_SLOTS:
    void doUpdate();

private:
    Plasma::FrameSvg *m_frameSvg;
    FrameSvgItemMargins *m_margins;
};

}

#endif
