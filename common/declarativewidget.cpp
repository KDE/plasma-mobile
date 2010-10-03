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

#include "declarativewidget.h"


#include <QtDeclarative/QDeclarativeComponent>
#include <QtDeclarative/QDeclarativeItem>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QGraphicsLinearLayout>
#include <QGraphicsScene>
#include <QTimer>

#include <KDebug>

namespace Plasma
{



class DeclarativeWidgetPrivate
{
public:
    DeclarativeWidgetPrivate(DeclarativeWidget *parent)
        : q(parent),
          engine(0),
          component(0),
          root(0),
          delay(false)
    {
    }

    ~DeclarativeWidgetPrivate()
    {
    }

    void errorPrint();
    void execute(const QString &fileName);
    void finishExecute();
    void scheduleExecutionEnd();


    DeclarativeWidget *q;

    QString qmlPath;
    QDeclarativeEngine* engine;
    QDeclarativeComponent* component;
    QObject *root;
    bool delay : 1;
};

void DeclarativeWidgetPrivate::errorPrint()
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

void DeclarativeWidgetPrivate::execute(const QString &fileName)
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

    if (delay) {
        QTimer::singleShot(0, q, SLOT(scheduleExecutionEnd()));
    } else {
        scheduleExecutionEnd();
    }
}

void DeclarativeWidgetPrivate::scheduleExecutionEnd()
{
    if (component->isReady() || component->isError()) {
        finishExecute();
    } else {
        QObject::connect(component, SIGNAL(statusChanged(QDeclarativeComponent::Status)), q, SLOT(finishExecute()));
    }
}

void DeclarativeWidgetPrivate::finishExecute()
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
        const qreal width = object->property("width").toReal();
        const qreal height = object->property("height").toReal();
        if (width > 0 && height > 0) {
            q->setPreferredSize(width, height);
        } else {
            q->setPreferredSize(-1, -1);
        }
    }
    emit q->finished();
}



DeclarativeWidget::DeclarativeWidget(QGraphicsWidget *parent)
    : QGraphicsWidget(parent),
      d(new DeclarativeWidgetPrivate(this))
{
    setFlag(QGraphicsItem::ItemHasNoContents);
}

DeclarativeWidget::~DeclarativeWidget()
{
    delete d;
}

void DeclarativeWidget::setQmlPath(const QString &path)
{
    d->qmlPath = path;
    d->execute(path);
}

QString DeclarativeWidget::qmlPath() const
{
    return d->qmlPath;
}

void DeclarativeWidget::setInitializationDelayed(const bool delay)
{
    d->delay = delay;
}

bool DeclarativeWidget::isInitializationDelayed() const
{
    return d->delay;
}

QDeclarativeEngine* DeclarativeWidget::engine()
{
    return d->engine;
}

QObject *DeclarativeWidget::rootObject() const
{
    return d->root;
}

QDeclarativeComponent *DeclarativeWidget::mainComponent() const
{
    return d->component;
}

void DeclarativeWidget::resizeEvent(QGraphicsSceneResizeEvent *event)
{
    QGraphicsWidget::resizeEvent(event);

    if (d->root) {
        d->root->setProperty("width", size().width());
        d->root->setProperty("height", size().height());
    }
}


} // namespace Plasma

#include <declarativewidget.moc>

