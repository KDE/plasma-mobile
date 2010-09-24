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

#include "filedialogproxy.h"

#include <QScriptEngine>

#include <KDebug>

FileDialogProxy::FileDialogProxy(KFileDialog::OperationMode mode, QObject *parent)
    : QObject(parent),
      m_dialog(new KFileDialog(KUrl("~"), QString(), 0))
{
    m_dialog->setOperationMode(mode);
    connect(m_dialog, SIGNAL(finished()), this, SLOT(dialogFinished()));
}

FileDialogProxy::~FileDialogProxy()
{
    delete m_dialog;
}

KUrl FileDialogProxy::selectedUrl() const
{
    return m_dialog->selectedUrl();
}

void FileDialogProxy::setUrl(const KUrl &url)
{
    m_dialog->setUrl(url);
}

KUrl::List FileDialogProxy::selectedUrls() const
{
    return m_dialog->selectedUrls();
}

KUrl FileDialogProxy::baseUrl() const
{
    return m_dialog->baseUrl();
}

QString FileDialogProxy::selectedFile() const
{
    return m_dialog->selectedFile();
}

QStringList FileDialogProxy::selectedFiles() const
{
    return m_dialog->selectedFiles();
}

QString FileDialogProxy::filter() const
{
    return m_dialog->currentFilter();
}

void FileDialogProxy::setFilter(const QString &filter)
{
    m_dialog->setFilter(filter);
}

bool FileDialogProxy::localOnly() const
{
    return m_dialog->mode() & KFile::LocalOnly;
}

void FileDialogProxy::setLocalOnly(bool localOnly)
{
    if (localOnly) {
        m_dialog->setMode(m_dialog->mode() ^ KFile::LocalOnly);
    } else {
        m_dialog->setMode(m_dialog->mode() | KFile::LocalOnly);
    }
}

bool FileDialogProxy::directoriesOnly() const
{
    return m_dialog->mode() & KFile::Directory;
}

void FileDialogProxy::setDirectoriesOnly(bool directoriesOnly)
{
    if (directoriesOnly) {
        m_dialog->setMode(m_dialog->mode() ^ KFile::Directory);
    } else {
        m_dialog->setMode(m_dialog->mode() | KFile::Directory);
    }
}

bool FileDialogProxy::existingOnly() const
{
    return m_dialog->mode() & KFile::ExistingOnly;
}

void FileDialogProxy::setExistingOnly(bool existingOnly)
{
    if (existingOnly) {
        m_dialog->setMode(m_dialog->mode() ^ KFile::ExistingOnly);
    } else {
        m_dialog->setMode(m_dialog->mode() | KFile::ExistingOnly);
    }
}

void FileDialogProxy::show()
{
    m_dialog->show();
}

void FileDialogProxy::dialogFinished()
{
    if (m_dialog->result() == QDialog::Accepted) {
        emit accepted(this);
    }
    emit finished(this);
}

Q_DECLARE_METATYPE(FileDialogProxy *)
typedef FileDialogProxy* FileDialogProxyPtr;
QScriptValue qScriptValueFromFileDialogProxy(QScriptEngine *engine, const FileDialogProxyPtr &fd)
{
    return engine->newQObject(const_cast<FileDialogProxy *>(fd), QScriptEngine::AutoOwnership,
                              QScriptEngine::PreferExistingWrapperObject | QScriptEngine::ExcludeSuperClassContents);
}

void fileDialogProxyFromQScriptValue(const QScriptValue &scriptValue, FileDialogProxyPtr &fd)
{
    QObject *obj = scriptValue.toQObject();
    fd = static_cast<FileDialogProxy *>(obj);
}

void FileDialogProxy::registerWithRuntime(QScriptEngine *engine)
{
    QScriptValue global = engine->globalObject();
    qScriptRegisterMetaType<FileDialogProxy*>(engine, qScriptValueFromFileDialogProxy, fileDialogProxyFromQScriptValue);
    global.setProperty("OpenFileDialog", engine->newFunction(FileDialogProxy::fileDialogOpen));
    global.setProperty("SaveFileDialog", engine->newFunction(FileDialogProxy::fileDialogSave));
}

QScriptValue FileDialogProxy::fileDialogSave(QScriptContext *context, QScriptEngine *engine)
{
    QObject *parent = 0;
    if (context->argumentCount()) {
        parent = context->argument(0).toQObject();
    }

    FileDialogProxy *fd = new FileDialogProxy(KFileDialog::Saving, parent);
    return engine->newQObject(fd, QScriptEngine::AutoOwnership, QScriptEngine::ExcludeSuperClassContents);
}

QScriptValue FileDialogProxy::fileDialogOpen(QScriptContext *context, QScriptEngine *engine)
{
    QObject *parent = 0;
    if (context->argumentCount()) {
        parent = context->argument(0).toQObject();
    }

    FileDialogProxy *fd = new FileDialogProxy(KFileDialog::Opening, parent);
    return engine->newQObject(fd, QScriptEngine::AutoOwnership, QScriptEngine::ExcludeSuperClassContents);
}

#include "filedialogproxy.moc"

