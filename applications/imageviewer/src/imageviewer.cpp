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

#include "imageviewer.h"
#include "dirmodel.h"
#include "kdeclarativeview.h"

#include <QDeclarativeContext>
#include <QFileInfo>

#include <KAction>
#include <KCmdLineArgs>
#include <KConfigGroup>
#include <KIcon>
#include <KStandardAction>

#include <Plasma/Theme>


ImageViewer::ImageViewer()
    : KDeclarativeMainWindow()
{
    declarativeView()->setPackageName("org.kde.active.imageviewer");

    // Filter the supplied argument through KUriFilter and then
    // make the resulting url known to the webbrowser component
    // as startupArguments property
    m_dirModel = new DirModel(this);
    if (startupArguments().count()) {
        KUrl uri(startupArguments()[0]);
        QVariant a = QVariant(QStringList(uri.prettyUrl()));
        if (!uri.prettyUrl().isEmpty()) {
            if (!uri.isLocalFile() || !QFileInfo(uri.toLocalFile()).isDir()) {
                uri = uri.upUrl();
            }
            m_dirModel->setUrl(uri.prettyUrl());
        }
    }
    declarativeView()->rootContext()->setContextProperty("dirModel", m_dirModel);
}

ImageViewer::~ImageViewer()
{
}


#include "imageviewer.moc"
