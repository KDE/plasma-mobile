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
#ifndef DECLARATIVESVG_P
#define DECLARATIVESVG_P

#include <QDeclarativeItem>

namespace Plasma {

    class Svg;

class DeclarativeSvg : public QDeclarativeItem
{
    Q_OBJECT



public:
    DeclarativeSvg(QDeclarativeItem *parent=0);
    ~DeclarativeSvg();

    void setImagePath(const QString &path);
    QString imagePath() const;

    void setElementID(const QString &elementID);
    QString elementID() const;

protected:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget);

private:
    Plasma::Svg *m_svg;
    QString m_elementID;
};
}

#endif
