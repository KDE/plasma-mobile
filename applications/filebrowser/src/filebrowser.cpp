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
#include "kdeclarativeview.h"

#include <QDeclarativeContext>
#include <QFileInfo>

#include <KAction>
#include <KCmdLineArgs>
#include <KConfigGroup>
#include <KIcon>
#include <KStandardAction>
#include <KStandardDirs>
#include <KServiceTypeTrader>

#include <kio/copyjob.h>
#include <Plasma/Theme>


FileBrowser::FileBrowser()
    : KDeclarativeMainWindow(),
      m_emptyProcess(0)
{
    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

    declarativeView()->setPackageName("org.kde.active.filebrowser");

    declarativeView()->rootContext()->setContextProperty("exclusiveResourceType", args->getOption("resourceType"));

    QStringList mimeTypes = args->getOption("mimeTypes").split(',');
    declarativeView()->rootContext()->setContextProperty("exclusiveMimeTypes", mimeTypes);

    //FIXME: need more elegant and pluggable way
    if (args->getOption("resourceType") == "nfo:Image") {
        setWindowIcon(KIcon("active-image-viewer"));
        setPlainCaption(i18n("Images"));
    }
}

FileBrowser::~FileBrowser()
{
}

QString FileBrowser::packageForMimeType(const QString &mimeType)
{
     KService::List services = KServiceTypeTrader::self()->query("Active/FileBrowserPart", QString("'%1' in MimeTypes").arg(mimeType));

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
        //kDebug() << service->property("X-KDE-PluginInfo-Name") << " :: " << description;
        kDebug() << service->property("X-KDE-PluginInfo-Name") << "\t\t" << description.toLocal8Bit().data();
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

    m_emptyProcess = new KProcess(this);
    connect(m_emptyProcess, SIGNAL(finished(int,QProcess::ExitStatus)),
            this, SLOT(emptyFinished(int,QProcess::ExitStatus)));
    (*m_emptyProcess) << KStandardDirs::findExe("ktrash") << "--empty";
    m_emptyProcess->start();
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
    KUrl::List urls;
    foreach (const QVariant &var, src) {
        urls << var.toUrl();
    }
    KIO::copy(urls, KUrl(dest));
}

void FileBrowser::trash(const QVariantList &files)
{
    KUrl::List urls;
    foreach (const QVariant &var, files) {
        urls << var.toUrl();
    }
    KIO::trash(urls);
}

#include "filebrowser.moc"
