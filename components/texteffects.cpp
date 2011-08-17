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

#include "texteffects.h"

#include <QPainter>

#include <KDebug>

#include <Plasma/PaintUtils>

TextEffects::TextEffects(QDeclarativeItem *parent)
    : QDeclarativeItem(parent),
      m_radius(3),
      m_horizontalOffset(0),
      m_verticalOffset(0)
{
    setFlag(QGraphicsItem::ItemHasNoContents, false);
    m_font = Plasma::Theme::defaultTheme()->font(Plasma::Theme::DesktopFont);
}

TextEffects::~TextEffects()
{
}

QString TextEffects::text() const
{
    return m_text;
}

void TextEffects::setText(const QString &text)
{
    if (text == m_text) {
        return;
    }

    m_text = text;
    refreshPixmap();
    setWidth(m_pixmap.width());
    setHeight(m_pixmap.height());
    emit textChanged(text);
    update();
}

int TextEffects::pixelSize() const
{
    return m_font.pixelSize();
}

void TextEffects::setPixelSize(int size)
{
    if (size == m_font.pixelSize()) {
        return;
    }

    m_font.setPixelSize(size);
    refreshPixmap();
    setWidth(m_pixmap.width());
    setHeight(m_pixmap.height());
    emit pixelSizeChanged(size);
    update();
}

int TextEffects::pointSize() const
{
    return m_font.pointSize();
}

void TextEffects::setPointSize(int size)
{
    if (size == m_font.pointSize()) {
        return;
    }

    m_font.setPointSize(size);
    refreshPixmap();
    setWidth(m_pixmap.width());
    setHeight(m_pixmap.height());
    emit pointSizeChanged(size);
    update();
}

bool TextEffects::bold() const
{
    return m_font.bold();
}

void TextEffects::setBold(bool bold)
{
    if (bold == m_font.bold()) {
        return;
    }

    m_font.setBold(bold);
    refreshPixmap();
    setWidth(m_pixmap.width());
    setHeight(m_pixmap.height());
    emit boldChanged(bold);
    update();
}

int TextEffects::radius() const
{
    return m_radius;
}

void TextEffects::setRadius(int radius)
{
    if (radius == m_radius) {
        return;
    }

    m_radius = radius;
    refreshPixmap();
    setWidth(m_pixmap.width());
    setHeight(m_pixmap.height());
    emit radiusChanged(radius);
    update();
}

int TextEffects::horizontalOffset() const
{
    return m_horizontalOffset;
}

void TextEffects::setHorizontalOffset(int horizontalOffset)
{
    if (horizontalOffset == m_horizontalOffset) {
        return;
    }

    m_horizontalOffset = horizontalOffset;
    refreshPixmap();
    setWidth(m_pixmap.width());
    setHeight(m_pixmap.height());
    emit horizontalOffsetChanged(horizontalOffset);
    update();
}

int TextEffects::verticalOffset() const
{
    return m_verticalOffset;
}

void TextEffects::setVerticalOffset(int verticalOffset)
{
    if (verticalOffset == m_verticalOffset) {
        return;
    }

    m_verticalOffset = verticalOffset;
    refreshPixmap();
    setWidth(m_pixmap.width());
    setHeight(m_pixmap.height());
    emit verticalOffsetChanged(verticalOffset);
    update();
}

QColor TextEffects::color() const
{
    return m_verticalOffset;
}

void TextEffects::setColor(const QColor &color)
{
    if (color == m_color) {
        return;
    }

    m_color = color;
    refreshPixmap();
    setWidth(m_pixmap.width());
    setHeight(m_pixmap.height());
    emit colorChanged(color);
    update();
}

void TextEffects::refreshPixmap()
{
    QColor shadowColor = qGray(m_color.red(), m_color.green(), m_color.blue()) > 120?Qt::black:Qt::white;
    m_pixmap = Plasma::PaintUtils::shadowText(m_text, m_font, m_color, shadowColor, QPoint(m_horizontalOffset, m_verticalOffset), m_radius);
}

void TextEffects::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    //FIXME: better control of the halo strength
    painter->drawPixmap(QPoint(), m_pixmap);
}

#include "texteffects.moc"
