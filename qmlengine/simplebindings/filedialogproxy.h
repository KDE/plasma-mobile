/*
 *   Copyright 2009 Aaron J. Seigo <aseigo@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef FILEDIALOGPROXY_H
#define FILEDIALOGPROXY_H

#include <QObject>
#include <QScriptValue>

#include <KFileDialog>

class QScriptEngine;
class QScriptContext;

class FileDialogProxy : public QObject
{
    Q_OBJECT
    Q_PROPERTY(KUrl url READ selectedUrl WRITE setUrl)
    Q_PROPERTY(KUrl::List urls READ selectedUrls)
    Q_PROPERTY(KUrl baseUrl READ baseUrl)
    Q_PROPERTY(QString file READ selectedFile)
    Q_PROPERTY(QStringList files READ selectedFiles)
    Q_PROPERTY(QString filter READ filter WRITE setFilter)
    Q_PROPERTY(bool localOnly READ localOnly WRITE setLocalOnly)
    Q_PROPERTY(bool directoriesOnly READ directoriesOnly WRITE setDirectoriesOnly)
    Q_PROPERTY(bool existingOnly READ existingOnly WRITE setExistingOnly)

public:
    FileDialogProxy(KFileDialog::OperationMode mode, QObject *parent = 0);
    ~FileDialogProxy();

    KUrl selectedUrl() const;
    void setUrl(const KUrl &url);

    KUrl::List selectedUrls() const;
    KUrl baseUrl() const;
    QString selectedFile() const;
    QStringList selectedFiles() const;

    QString filter() const;
    void setFilter(const QString &filter);

    bool localOnly() const;
    void setLocalOnly(bool localOnly);

    bool directoriesOnly() const;
    void setDirectoriesOnly(bool directoriesOnly);

    bool existingOnly() const;
    void setExistingOnly(bool existingOnly);

    static void registerWithRuntime(QScriptEngine *global);
    static QScriptValue fileDialogSave(QScriptContext *context, QScriptEngine *engine);
    static QScriptValue fileDialogOpen(QScriptContext *context, QScriptEngine *engine);

public Q_SLOTS:
    void show();

Q_SIGNALS:
    void accepted(FileDialogProxy *);
    void finished(FileDialogProxy *);

private Q_SLOTS:
    void dialogFinished();

private:
    KFileDialog *m_dialog;
};

#endif
