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

#include <QQuickView>

#include <QProcess>

class DirModel;


class FileBrowser : public QQuickView {
    Q_OBJECT
public:
    FileBrowser();
    virtual ~FileBrowser();

    Q_INVOKABLE QString viewerPackageForType(const QString &mimeType);
    Q_INVOKABLE QString browserPackageForType(const QString &type);
    Q_INVOKABLE void emptyTrash();
    Q_INVOKABLE void copy(const QVariantList &src, const QString &dest);
    Q_INVOKABLE void trash(const QVariantList &files);

    void setResourceType(const QString &resourceType);
    QString resourceType() const;

    void setMimeTypes(const QString &mimeTypes);
    QString mimeTypes() const;

protected Q_SLOTS:
    void emptyFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QProcess *m_emptyProcess;
    QString m_resourceType;
    QString m_mimeTypes;
};

#endif // FILEBROWSER_H
