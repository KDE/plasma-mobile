/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "busywidget.h"

#include <QPainter>
#include <QPaintEvent>
#include <QTimer>

#include <KDebug>
#include <KWindowSystem>

#include <Plasma/FrameSvg>
#include <Plasma/Svg>

BusyWidget::BusyWidget(QWidget *parent)
    : QWidget(parent),
      m_rotation(0)
{
    setAutoFillBackground(false);
    setAttribute(Qt::WA_TranslucentBackground);
    setAttribute(Qt::WA_DeleteOnClose);
    setWindowFlags(windowFlags() | Qt::FramelessWindowHint);

    m_svg = new Plasma::Svg(this);
    m_svg->setImagePath("widgets/busywidget");
    m_svg->setContainsMultipleImages(true);

    m_background = new Plasma::FrameSvg(this);
    m_background->setImagePath("widgets/background");
    m_background->setEnabledBorders((Plasma::FrameSvg::EnabledBorders)(Plasma::FrameSvg::AllBorders^Plasma::FrameSvg::BottomBorder));
    m_background->resizeFrame(size());

    m_rotationTimer = new QTimer(this);
    connect(m_rotationTimer, SIGNAL(timeout()), this, SLOT(refreshSpinner()));
    m_rotationTimer->start(40);

    //suicide after 20 seconds
    QTimer::singleShot(20*1000, this, SLOT(close()));

    hide();
}

BusyWidget::~BusyWidget()
{
}

void BusyWidget::resizeEvent(QResizeEvent *event)
{
    m_background->resizeFrame(event->size());
}

void BusyWidget::refreshSpinner()
{

    m_rotation += 9;

    const qreal overflow = m_rotation - 360;
    if ( overflow > 0) {
        m_rotation = overflow;
    }

    QRect spinnerRect(QPoint(0, 0), QSize(64, 64));
    const int topMargin = m_background->marginSize(Plasma::TopMargin);
    spinnerRect.moveCenter(QRect(QPoint(0, topMargin), size()-QSize(0, topMargin)).center());
    update(spinnerRect);
}

void BusyWidget::paintEvent(QPaintEvent *e)
{
    QPainter p(this);
    p.setCompositionMode(QPainter::CompositionMode_Source);
    m_background->paintFrame(&p);
    p.setCompositionMode(QPainter::CompositionMode_SourceOver);

    QRectF spinnerRect(QPoint(0, 0), QSize(64, 64));
    const int topMargin = m_background->marginSize(Plasma::TopMargin);
    spinnerRect.moveCenter(QRect(QPoint(0, topMargin), size()-QSize(0, topMargin)).center());
    int intRotation = (int)m_rotation;

    if (!m_frames[intRotation]) {
        QPointF translatedPos(spinnerRect.width()/2, spinnerRect.height()/2);

        m_frames[intRotation] = QPixmap(spinnerRect.size().toSize());
        m_frames[intRotation].fill(Qt::transparent);

        QPainter buffPainter(&m_frames[intRotation]);

        buffPainter.setRenderHints(QPainter::SmoothPixmapTransform);
        buffPainter.translate(translatedPos);

        if (m_svg->hasElement("busywidget-shadow")) {
            buffPainter.save();
            buffPainter.translate(1,1);
            buffPainter.rotate(intRotation);
            m_svg->paint(&buffPainter, QRectF(-translatedPos.toPoint(), spinnerRect.size()), "busywidget-shadow");
            buffPainter.restore();
        }

        buffPainter.rotate(intRotation);
        m_svg->paint(&buffPainter, QRectF(-translatedPos.toPoint(), spinnerRect.size()), "busywidget");
    }

    p.drawPixmap(spinnerRect.topLeft().toPoint(), m_frames[intRotation]);

}

#include "busywidget.moc"

