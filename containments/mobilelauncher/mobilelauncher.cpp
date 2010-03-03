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
#include "qmlwidget.h"


//Qt
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtGui/QGraphicsLinearLayout>
#include <QStandardItemModel>

//KDE
#include <KDebug>
#include <KStandardDirs>

//Plasma
#include <Plasma/Corona>
#include <Plasma/RunnerManager>


using namespace Plasma;

MobileLauncher::MobileLauncher(QObject *parent, const QVariantList &args)
    : Containment(parent, args)
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

    m_qmlWidget = new Plasma::QmlWidget(this);
    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(this);
    lay->addItem(m_qmlWidget);

    m_qmlWidget->setQmlPath(KStandardDirs::locate("data", "plasma-mobile/containments/mobilelauncher/view.qml"));

    m_runnermg->launchQuery("Network");

    if (m_qmlWidget->engine()) {
        QDeclarativeContext *ctxt = m_qmlWidget->engine()->rootContext();
        if (ctxt) {
            ctxt->setContextProperty("myModel", m_runnerModel);
        }
    }
}


void MobileLauncher::setQueryMatches(const QList<Plasma::QueryMatch> &matches)
{
    foreach (Plasma::QueryMatch match, matches) {
        m_runnerModel->appendRow(new QStandardItem(match.text()));
    }

}

K_EXPORT_PLASMA_APPLET(mobilelauncher, MobileLauncher)

#include "mobilelauncher.moc"
