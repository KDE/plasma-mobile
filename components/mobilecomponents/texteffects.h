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

#ifndef TEXTEFFECTS_H
#define TEXTEFFECTS_H

#include <QDeclarativeItem>

#include <QFont>
#include <QPixmap>

namespace Plasma {
    class Svg;
}

class TextEffects : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(int pixelSize READ pixelSize WRITE setPixelSize NOTIFY pixelSizeChanged)
    Q_PROPERTY(int pointSize READ pointSize WRITE setPointSize NOTIFY pointSizeChanged)
    Q_PROPERTY(bool bold READ bold WRITE setBold NOTIFY boldChanged)
    Q_PROPERTY(int radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(int horizontalOffset READ horizontalOffset WRITE setHorizontalOffset NOTIFY horizontalOffsetChanged)
    Q_PROPERTY(int verticalOffset READ verticalOffset WRITE setVerticalOffset NOTIFY verticalOffsetChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(Effect effect READ effect WRITE setEffect NOTIFY effectChanged)

public:
    enum Effect {
        ShadowedText,
        TexturedText
    };
    Q_ENUMS(Effect)

    TextEffects(QDeclarativeItem *parent = 0);
    ~TextEffects();

    QString text() const;
    void setText(const QString &text);

    int pixelSize() const;
    void setPixelSize(int size);
    int pointSize() const;
    void setPointSize(int size);

    bool bold() const;
    void setBold(bool bold);

    int radius() const;
    void setRadius(int radius);

    int horizontalOffset() const;
    void setHorizontalOffset(int horizontalOffset);
    int verticalOffset() const;
    void setVerticalOffset(int verticalOffset);

    QColor color() const;
    void setColor(const QColor &color);

    Effect effect() const;
    void setEffect(Effect effect);

    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget);

private:
    void refreshPixmap();

Q_SIGNALS:
    void textChanged(const QString &test);
    void pixelSizeChanged(int pixelSize);
    void pointSizeChanged(int pointSize);
    void boldChanged(bool bold);
    void radiusChanged(int radius);
    void horizontalOffsetChanged(int horizontalOffset);
    void verticalOffsetChanged(int verticalOffset);
    void colorChanged(const QColor &color);
    void effectChanged(Effect effect);

private:
    QString m_text;
    QPixmap m_pixmap;
    QFont m_font;
    int m_radius;
    int m_horizontalOffset;
    int m_verticalOffset;
    QColor m_color;
    Effect m_effect;
    Plasma::Svg *m_texture;
};

#endif
