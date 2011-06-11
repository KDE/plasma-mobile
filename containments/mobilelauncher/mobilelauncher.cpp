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
#include "models/krunnermodel.h"


//Qt
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeItem>
#include <QtGui/QGraphicsLinearLayout>
#include <QStandardItemModel>
#include <QTimer>

//KDE
#include <KDebug>
#include <KStandardDirs>

//Plasma
#include <Plasma/Corona>
#include <Plasma/DeclarativeWidget>
#include <Plasma/RunnerManager>


MobileLauncher::MobileLauncher(QObject *parent, const QVariantList &args)
    : Containment(parent, args),
      m_view(0)
{
    setHasConfigurationInterface(false);
    kDebug() << "!!! loading mobile launcher";

    // At some point it has to be a custom constainment
    setContainmentType(Containment::CustomContainment);
}

MobileLauncher::~MobileLauncher()
{
}

void MobileLauncher::init()
{
    Containment::init();

    m_queryTimer = new QTimer(this);
    m_queryTimer->setSingleShot(true);
    connect(m_queryTimer, SIGNAL(timeout()), this, SLOT(updateQuery()));

    m_runnerModel = new KRunnerModel(this);
    //m_runnerModel->setQuery("Network");

    setContentsMargins(0, 0, 0, 0);

    m_declarativeWidget = new Plasma::DeclarativeWidget(this);
    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(this);
    lay->setContentsMargins(0, 0, 0, 0);
    lay->addItem(m_declarativeWidget);

    m_declarativeWidget->setQmlPath(KStandardDirs::locate("data", "plasma-mobile/containments/mobilelauncher/view.qml"));

    if (m_declarativeWidget->engine()) {
        QDeclarativeContext *ctxt = m_declarativeWidget->engine()->rootContext();
        if (ctxt) {
            ctxt->setContextProperty("runnerModel", m_runnerModel);
        }
        QDeclarativeItem *item = qobject_cast<QDeclarativeItem *>(m_declarativeWidget->rootObject());

        if (item) {
            m_view = item->findChild<QDeclarativeItem*>("appsView");

            if (m_view) {
                connect(m_view, SIGNAL(clicked(const QString &)), this, SLOT(itemActivated(const QString &)));
            }
        }
    }
    Plasma::Corona *c = corona();
    if (c) {
        connect(c, SIGNAL(screenOwnerChanged(int, int, Plasma::Containment *)), this, SLOT(updateActivity(int, int, Plasma::Containment *)));
    }
}

void MobileLauncher::updateActivity(int wasScreen, int isScreen, Plasma::Containment *containment)
{
    Q_UNUSED(wasScreen)
    Q_UNUSED(wasScreen)

    m_queryTimer->start(1000);
    setBusy(true);
}

void MobileLauncher::updateQuery()
{
    Plasma::Containment *containment = corona()->containmentForScreen(0);
    if (containment) {
        m_runnerModel->setDefaultQuery(containment->activity());
        m_runnerModel->setQuery(containment->activity());
    }
    setBusy(false);
}

void MobileLauncher::itemActivated(const QString &url)
{
    kWarning() << "URL clicked" << url;

    KRunnerItemHandler::openUrl(url);
}

K_EXPORT_PLASMA_APPLET(mobilelauncher, MobileLauncher)

#include "mobilelauncher.moc"
