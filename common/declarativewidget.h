/*
 *   Copyright 2010 Marco Martin <mart@kde.org>
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

#ifndef PLASMA_DECLARATIVEWIDGET_H
#define PLASMA_DECLARATIVEWIDGET_H

#include <QtGui/QGraphicsWidget>


class QDeclarativeEngine;
class QDeclarativeComponent;

namespace Plasma
{

class DeclarativeWidgetPrivate;

/**
 * @class DeclarativeWidget plasma/declarativewidget.h <Plasma/DeclarativeWidget>
 *
 * @author Marco Martin <mart@kde.org>
 *
 * @short A widget that contains an entire QML context, with its own declarative engine
 *
 * Plasma::DeclarativeWidget provides a class for conveniently use QML based
 * declarative user interfaces inside Plasma widgets.
 * To one DeclarativeWidget corresponds one QML file (that can eventually include others)
 * tere will be its own QDeclarativeEngine with a single root object,
 * described in the QML file.
 */
class DeclarativeWidget : public QGraphicsWidget
{
    Q_OBJECT

    Q_PROPERTY(QString qmlPath READ qmlPath WRITE setQmlPath)
    Q_PROPERTY(bool initializationDelayed READ isInitializationDelayed WRITE setInitializationDelayed)
    Q_PROPERTY(QObject * rootObject READ rootObject)

public:

    /**
     * Constructs a new DeclarativeWidget
     *
     * @param parent the parent of this widget
     */
    explicit DeclarativeWidget(QGraphicsWidget *parent = 0);
    ~DeclarativeWidget();

    /**
     * Sets the path of the QML file to parse and execute
     *
     * @param path the absolute path of a QML file
     */
    void setQmlPath(const QString &path);

    /**
     * @return the absolute path of the current QML file
     */
    QString qmlPath() const;

    /**
     * Sets whether the execution of the QML file has to be delayed later in the event loop. It has to be called before setQmlPath().
     * In this case will be possible to assign new objects in the main engine context
     * before the main component gets initialized.
     * So it will be possible to access it immediately from the QML code.
     *
     * @param delay if true the initilization of the QML file will be delayed 
     *              at the end of the event loop
     */
    void setInitializationDelayed(const bool delay);

    /**
     * @return true if the initilization of the QML file will be delayed 
     *              at the end of the event loop
     */
    bool isInitializationDelayed() const;

    /**
     * @return the declarative engine that runs the qml file assigned to this widget.
     */
    QDeclarativeEngine* engine();

    /**
     * @return the root object of the declarative object tree
     */
    QObject *rootObject() const;

    /**
     * @return the main QDeclarativeComponent of the engine
     */
    QDeclarativeComponent *mainComponent() const;

protected:
    void resizeEvent(QGraphicsSceneResizeEvent *event);

Q_SIGNALS:
    /**
     * Emitted when the parsing and execution of the QML file is terminated
     */
    void finished();

private:
    friend class DeclarativeWidgetPrivate;
    DeclarativeWidgetPrivate * const d;

    Q_PRIVATE_SLOT(d, void finishExecute())
    Q_PRIVATE_SLOT(d, void scheduleExecutionEnd())
};

} // namespace Plasma

#endif // multiple inclusion guard
