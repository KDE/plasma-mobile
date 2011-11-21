#include <QAction>
#include <QApplication>
#include <QDialog>
#include <QLineEdit>
#include <QTreeView>
#include <QVBoxLayout>

#include "../runnermodel.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QWidget *widget = new QWidget;
    QVBoxLayout *layout = new QVBoxLayout(widget);

    RunnerModel *runnerModel = new RunnerModel(widget);

    QLineEdit *input = new QLineEdit(widget);
    QObject::connect(input, SIGNAL(textChanged(QString)), runnerModel, SLOT(startQuery(QString)));
    layout->addWidget(input);

    QTreeView *view = new QTreeView(widget);
    view->setModel(runnerModel);
    layout->addWidget(view);

    QAction *quit = new QAction(widget);
    quit->setShortcut(Qt::CTRL + Qt::Key_Q);
    QObject::connect(quit, SIGNAL(triggered()), &app, SLOT(quit()));

    widget->addAction(quit);
    widget->show();
    return app.exec();
}

