#include <QAction>
#include <QApplication>
#include <QDialog>
#include <QPushButton>
#include <QTreeView>
#include <QVBoxLayout>
#include <QDebug>


#include "../applicationlistmodel.h"
#include "modeltest.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QWidget *widget = new QWidget;
    QVBoxLayout *layout = new QVBoxLayout(widget);

    ApplicationListModel *applicationListModel = new ApplicationListModel(widget);
    ModelTest *test = new ModelTest(applicationListModel, widget);

    QTreeView *view = new QTreeView(widget);
    QPushButton *upButton = new QPushButton(widget);
    upButton->setText("Move Up");
    QObject::connect(upButton, &QPushButton::clicked, [=](){
        QModelIndex idx = view->currentIndex();
        if (idx.row() > 0) {
            applicationListModel->moveItem(idx.row(), idx.row()-1);
        }
    });
    QPushButton *downButton = new QPushButton(widget);
    downButton->setText("Move Down");
    QObject::connect(downButton, &QPushButton::clicked, [=](){
        QModelIndex idx = view->currentIndex();
        if (idx.row() > 0) {
            applicationListModel->moveItem(idx.row(), idx.row()+1);
        }
    });
    layout->addWidget(upButton);
    layout->addWidget(downButton);

    view->setDragDropMode(QAbstractItemView::InternalMove);
    view->setModel(applicationListModel);
    applicationListModel->loadApplications();
    layout->addWidget(view);

    QAction *quit = new QAction(widget);
    quit->setShortcut(Qt::CTRL + Qt::Key_Q);
    QObject::connect(quit, SIGNAL(triggered()), &app, SLOT(quit()));

    widget->addAction(quit);
    widget->show();
    return app.exec();
}
