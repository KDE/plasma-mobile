/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
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

#include "filebrowser.h"

#include <QDebug>
#include <QQmlContext>
#include <QStandardPaths>

#include <KConfigGroup>
#include <KServiceTypeTrader>
#include <kdeclarative/kdeclarative.h>
#include <kio/copyjob.h>

FileBrowser::FileBrowser()
    : QQuickView(),
      m_emptyProcess(0)
{

    KDeclarative::KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.setupBindings();

    rootContext()->setContextProperty("exclusiveResourceType", resourceType());
    rootContext()->setContextProperty("application", this);
    QString mimeString = mimeTypes();
    if (mimeString.isEmpty()) {
        rootContext()->setContextProperty("exclusiveMimeTypes", QStringList());
    } else {
        QStringList mimeTypes = mimeString.split(',');
        rootContext()->setContextProperty("exclusiveMimeTypes", mimeTypes);
    }

    const QString mainQMlFile = QStandardPaths::locate(QStandardPaths::GenericDataLocation, "/plasma/plasmoids/org.kde.plasma.active.filebrowser/contents/ui/main.qml", QStandardPaths::LocateFile);
    setSource(QUrl::fromLocalFile(mainQMlFile));
    setResizeMode(QQuickView::SizeRootObjectToView);
    //FIXME: need more elegant and pluggable way
 /*
    if (!startupArguments().isEmpty()) {
        KMimeType::Ptr t = KMimeType::findByUrl(startupArguments().first());
        declarativeView()->rootContext()->setContextProperty("startupMimeType", t->name());
    }*/
}

void FileBrowser::setResourceType(const QString &resourceType)
{
    if (resourceType == m_resourceType) {
        return;
    }

    m_resourceType = resourceType;
}

QString FileBrowser::resourceType() const
{
    return m_resourceType;
}


void FileBrowser::setMimeTypes(const QString &mimeTypes)
{
    if (mimeTypes == m_mimeTypes) {
        return;
    }

    m_mimeTypes = mimeTypes;
}

QString FileBrowser::mimeTypes() const
{
    return m_mimeTypes;
}


FileBrowser::~FileBrowser()
{
}

QString FileBrowser::viewerPackageForType(const QString &mimeType)
{
    if (mimeType.isEmpty()) {
        return QString();
    }

    KService::List services = KServiceTypeTrader::self()->query("Active/FileBrowserPart", QString("('%1' in MimeTypes or '%1' in ResourceTypes) and 'Viewer' in SupportedComponents").arg(mimeType));

    foreach (const KService::Ptr &service, services) {
        if (service->noDisplay()) {
            continue;
        }
        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }
        //qDebug() << service->property("X-KDE-PluginInfo-Name") << " :: " << description;
        qDebug() << service->property("X-KDE-PluginInfo-Name") << "\t\t" << description.toLocal8Bit().data();
        return service->property("X-KDE-PluginInfo-Name").toString();
    }
    return QString();
}

QString FileBrowser::browserPackageForType(const QString &type)
{
    if (type.isEmpty()) {
        return QString();
    }

    KService::List services = KServiceTypeTrader::self()->query("Active/FileBrowserPart", QString("('%1' in MimeTypes or '%1' in ResourceTypes) and 'Browser' in SupportedComponents").arg(type));

    foreach (const KService::Ptr &service, services) {
        if (service->noDisplay()) {
            continue;
        }
        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }
        qDebug() << service->property("X-KDE-PluginInfo-Name") << " :: " << description;
        qDebug() << service->property("X-KDE-PluginInfo-Name") << "\t\t" << description.toLocal8Bit().data();
        return service->property("X-KDE-PluginInfo-Name").toString();
    }
    return QString();
}

void FileBrowser::emptyTrash()
{
    // We can't use KonqOperations here. To avoid duplicating its code (small, though),
    // we can simply call ktrash.

    if (m_emptyProcess) {
        return;
    }

    m_emptyProcess = new QProcess(this);
    connect(m_emptyProcess, SIGNAL(finished(int,QProcess::ExitStatus)),
            this, SLOT(emptyFinished(int,QProcess::ExitStatus)));

    const QString ktrash = QStandardPaths::locate(QStandardPaths::ApplicationsLocation,QStringLiteral("/trash5"), QStandardPaths::LocateFile);
    QStringList arguments;
    arguments << QStringLiteral("--empty");
    m_emptyProcess->start(ktrash, arguments);
}

void FileBrowser::emptyFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitCode)
    Q_UNUSED(exitStatus)

    //TODO: check the exit status and let the user know if it fails
    delete m_emptyProcess;
    m_emptyProcess = 0;
}

void FileBrowser::copy(const QVariantList &src, const QString &dest)
{
    QList<QUrl> urls;
    foreach (const QVariant &var, src) {
        QUrl url(var.toString());
        urls << url;
    }

    QUrl destination(dest);
    KIO::copy(urls, destination);
}

void FileBrowser::trash(const QVariantList &files)
{
    QList<QUrl> urls;
    foreach (const QVariant &var, files) {
        QUrl url(var.toString());
        urls << url;
    }
    KIO::trash(urls);
}

#include "filebrowser.moc"
