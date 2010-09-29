/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef PLASMA_QmlWIDGET_H
#define PLASMA_QmlWIDGET_H

#include <QtGui/QGraphicsWidget>


class QDeclarativeEngine;
class QDeclarativeComponent;

namespace Plasma
{

class QmlWidgetPrivate;


class QmlWidget : public QGraphicsWidget
{
    Q_OBJECT

public:

    /**
     * Constructs a new QmlWidget
     *
     * @arg parent the parent of this widget
     */
    explicit QmlWidget(QGraphicsWidget *parent = 0);
    ~QmlWidget();

    void setQmlPath(const QString &path);
    QString qmlPath() const;

    void setInitializationDelayed(const bool delay);
    bool isInitializationDelayed() const;

    QDeclarativeEngine* engine();
    QObject *rootObject() const;
    QDeclarativeComponent *mainComponent() const;

protected:
    void resizeEvent(QGraphicsSceneResizeEvent *event);

Q_SIGNALS:
    void finished();

private:
    friend class QmlWidgetPrivate;
    QmlWidgetPrivate * const d;

    Q_PRIVATE_SLOT(d, void finishExecute())
    Q_PRIVATE_SLOT(d, void scheduleExecutionEnd())
};

} // namespace Plasma

#endif // multiple inclusion guard
