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

#include "qmlwidget.h"


#include <QtDeclarative/QDeclarativeComponent>
#include <QtDeclarative/QDeclarativeItem>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QGraphicsLinearLayout>
#include <QGraphicsScene>

#include <KDebug>

namespace Plasma
{



class QmlWidgetPrivate
{
public:
    QmlWidgetPrivate(QmlWidget *parent)
        : q(parent),
          engine(0),
          component(0),
          root(0)
    {
    }

    ~QmlWidgetPrivate()
    {
    }

    void errorPrint();
    void execute(const QString &fileName);
    void finishExecute();


    QmlWidget *q;

    QString qmlPath;
    QDeclarativeEngine* engine;
    QDeclarativeComponent* component;
    QObject *root;
};

void QmlWidgetPrivate::errorPrint()
{
    QString errorStr = "Error loading QML file.\n";
    if(component->isError()){
        QList<QDeclarativeError> errors = component->errors();
        foreach (const QDeclarativeError &error, errors) {
            errorStr += (error.line()>0?QString::number(error.line()) + ": ":"")
                + error.description() + '\n';
        }
    }
    kWarning() << component->url().toString() + '\n' + errorStr;
}

void QmlWidgetPrivate::execute(const QString &fileName)
{
    if (fileName.isEmpty()) {
        kDebug() << "File name empty!";
        return;
    }

    if (engine) {
        delete engine;
    }

    if (component) {
        delete component;
    }

    engine = new QDeclarativeEngine(q);
    component = new QDeclarativeComponent(engine, fileName, q);

    if (component->isReady() || component->isError()) {
        finishExecute();
    } else {
        QObject::connect(component, SIGNAL(statusChanged(QDeclarativeComponent::Status)), q, SLOT(finishExecute()));
    }
}

void QmlWidgetPrivate::finishExecute()
{
    if (component->isError()) {
        errorPrint();
    }

    root = component->create();

    if (!root) {
        errorPrint();
    }

    kDebug() << "Execution of QML done!";
    QGraphicsWidget *widget = dynamic_cast<QGraphicsWidget*>(root);
    QGraphicsObject *object = dynamic_cast<QGraphicsObject *>(root);


    if (object) {
        static_cast<QGraphicsItem *>(object)->setParentItem(q);
        if (q->scene()) {
            q->scene()->addItem(object);
        }
    }

    if (widget) {
        q->setPreferredSize(-1,-1);
        QGraphicsLinearLayout *lay = static_cast<QGraphicsLinearLayout *>(q->layout());
        if (!lay) {
            lay = new QGraphicsLinearLayout(q);
            lay->setContentsMargins(0, 0, 0, 0);
        }
        lay->addItem(widget);
    } else {
        q->setLayout(0);
        q->setPreferredSize(object->property("width").toReal(), object->property("height").toReal());
    }
    emit q->finished();
}



QmlWidget::QmlWidget(QGraphicsWidget *parent)
    : QGraphicsWidget(parent),
      d(new QmlWidgetPrivate(this))
{
    setFlag(QGraphicsItem::ItemHasNoContents);
}

QmlWidget::~QmlWidget()
{
    delete d;
}

void QmlWidget::setQmlPath(const QString &path)
{
    d->qmlPath = path;
    d->execute(path);
}

QString QmlWidget::qmlPath() const
{
    return d->qmlPath;
}

QDeclarativeEngine* QmlWidget::engine()
{
    return d->engine;
}

QObject *QmlWidget::rootObject() const
{
    return d->root;
}

QDeclarativeComponent *QmlWidget::mainComponent() const
{
    return d->component;
}

void QmlWidget::resizeEvent(QGraphicsSceneResizeEvent *event)
{
    QGraphicsWidget::resizeEvent(event);

    if (d->root) {
        d->root->setProperty("width", size().width());
        d->root->setProperty("height", size().height());
    }
}


} // namespace Plasma

#include <qmlwidget.moc>

