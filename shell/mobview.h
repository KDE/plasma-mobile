/***************************************************************************
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>                      *
 *   Copyright 2009 Marco Martin <notmart@gmail.com>                       *
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

#ifndef MOBVIEW_H
#define MOBVIEW_H

#include <Plasma/Plasma>
#include <Plasma/View>

namespace Plasma
{
    class Containment;
} // namespace Plasma

class MobView : public Plasma::View
{
    Q_OBJECT
    Q_PROPERTY(int rotation READ rotation WRITE setRotation)

public:
    MobView(Plasma::Containment *containment, int uid, QWidget *parent = 0);
    ~MobView();

    void setUseGL(const bool on);
    bool useGL() const;

    void connectContainment(Plasma::Containment *containment);

    Plasma::Location location() const;
    Plasma::FormFactor formFactor() const;
    KConfigGroup config() const {return Plasma::View::config();}

    void setRotation(const int rotation);
    int rotation() const;

    void setDirection(const Plasma::Direction direction);
    Plasma::Direction direction() const;
    QSize transformedSize() const;

    static int mainViewId() { return 1; }

public Q_SLOTS:
    void setContainment(Plasma::Containment *containment);
    void updateGeometry();
    void rotateCounterClockwise();
    void rotateClockwise();

Q_SIGNALS:
    void locationChanged(const MobView *view);
    void geometryChanged();
    void containmentActivated();

protected:
    void drawBackground(QPainter *painter, const QRectF &rect);
    void resizeEvent(QResizeEvent *event);

private:
    bool m_useGL;
    Plasma::Direction m_direction;
    int m_rotation;
};

#endif // multiple inclusion guard
