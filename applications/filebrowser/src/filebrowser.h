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


#ifndef FILEBROWSER_H
#define FILEBROWSER_H

#include "kdeclarativemainwindow.h"

#include <KProcess>

class DirModel;


class FileBrowser : public KDeclarativeMainWindow
{
    Q_OBJECT
public:
    FileBrowser();
    virtual ~FileBrowser();

    Q_INVOKABLE QString packageForMimeType(const QString &mimeType);
    Q_INVOKABLE void emptyTrash();
    Q_INVOKABLE void copy(const QVariantList &src, const QString &dest);
    Q_INVOKABLE void trash(const QVariantList &files);

protected Q_SLOTS:
    void emptyFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    KProcess *m_emptyProcess;
};

#endif // FILEBROWSER_H
