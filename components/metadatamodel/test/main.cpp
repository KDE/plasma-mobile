#include <QAction>
#include <QApplication>
#include <QDialog>
#include <QLineEdit>
#include <QTreeView>
#include <QVBoxLayout>

#include "../metadatamodel.h"
#include "modeltest.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QWidget *widget = new QWidget;
    QVBoxLayout *layout = new QVBoxLayout(widget);

    MetadataModel *metadataModel = new MetadataModel(widget);
    new ModelTest(metadataModel, widget);

    /*QLineEdit *input = new QLineEdit(widget);
    QObject::connect(input, SIGNAL(textChanged(QString)), metadataModel, SLOT(startQuery(QString)));
    layout->addWidget(input);*/

    metadataModel->setResourceType("nfo:Application");
    

    QTreeView *view = new QTreeView(widget);
    view->setModel(metadataModel);
    layout->addWidget(view);

    QAction *quit = new QAction(widget);
    quit->setShortcut(Qt::CTRL + Qt::Key_Q);
    QObject::connect(quit, SIGNAL(triggered()), &app, SLOT(quit()));

    widget->addAction(quit);
    widget->show();
    return app.exec();
}
