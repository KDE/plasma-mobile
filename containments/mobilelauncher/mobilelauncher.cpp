/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

//own
#include "mobilelauncher.h"
#include <QStandardItemModel>

//Qt
#include <QtDeclarative/QDeclarativeComponent>
#include <QtDeclarative/QDeclarativeItem>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtGui/QGraphicsLinearLayout>

//KDE
#include <KDebug>
#include <KStandardDirs>

//Plasma
#include <Plasma/Corona>
#include <Plasma/RunnerManager>

using namespace Plasma;

MobileLauncher::MobileLauncher(QObject *parent, const QVariantList &args)
    : Containment(parent, args),
      m_engine(0),
      m_component(0),
      m_root(0),
      m_loaded(false)
{
    setHasConfigurationInterface(false);
    kDebug() << "!!! loading mobile launcher";

    // At some point it has to be a custom constainment
    //setContainmentType(Containment::CustomContainment);
}

MobileLauncher::~MobileLauncher()
{
}

void MobileLauncher::init()
{
    Containment::init();

    m_runnerModel = new QStandardItemModel(this);

    m_runnermg = new Plasma::RunnerManager(this);
    m_runnermg->reloadConfiguration();
    connect(m_runnermg, SIGNAL(matchesChanged(const QList<Plasma::QueryMatch>&)),
            this, SLOT(setQueryMatches(const QList<Plasma::QueryMatch>&)));

    execute(KStandardDirs::locate("appdata", "containments/mobilelauncher/view.qml"));
}

void MobileLauncher::errorPrint()
{
    m_loaded=false;
    QString errorStr = "Error loading QML file.\n";
    if(m_component->isError()){
        QList<QDeclarativeError> errors = m_component->errors();
        foreach (const QDeclarativeError &error, errors) {
            errorStr += (error.line()>0?QString::number(error.line()) + ": ":"")
                + error.description() + '\n';
        }
    }
    kWarning() << errorStr;
}

void MobileLauncher::setQueryMatches(const QList<Plasma::QueryMatch> &matches)
{
    foreach (Plasma::QueryMatch match, matches) {
        m_runnerModel->appendRow(new QStandardItem(match.text()));
    }

}

void MobileLauncher::execute(const QString &fileName)
{
    if (fileName.isEmpty()) {
        return;
    }

    if (m_engine) {
        delete m_engine;
    }

    if (m_component) {
        delete m_component;
    }

    m_engine = new QDeclarativeEngine(this);
    m_component = new QDeclarativeComponent(m_engine, fileName, this);


    m_runnermg->launchQuery("Network");

    QDeclarativeContext *ctxt = m_engine->rootContext();
    ctxt->setContextProperty("myModel", m_runnerModel);

    if (m_component->isReady() || m_component->isError()) {
        finishExecute();
    } else {
        QObject::connect(m_component, SIGNAL(statusChanged(QDeclarativeComponent::Status)), this, SLOT(finishExecute()));
    }
}

void MobileLauncher::constraintsEvent(Plasma::Constraints constraints)
{
    if (m_root && (constraints & Plasma::SizeConstraint)) {
        m_root->setProperty("width", size().width());
        m_root->setProperty("height", size().height());
    }
}

void MobileLauncher::finishExecute()
{
    if (m_component->isError()) {
        errorPrint();
    }

    m_root = m_component->create();

    if (!m_root) {
        errorPrint();
    }

    kDebug() << "Execution of QML done!";
    QGraphicsWidget *widget = dynamic_cast<QGraphicsWidget*>(m_root);
    QGraphicsObject *object = dynamic_cast<QGraphicsObject *>(m_root);
    corona()->addItem(object);
}

K_EXPORT_PLASMA_APPLET(mobilelauncher, MobileLauncher)

#include "mobilelauncher.moc"
