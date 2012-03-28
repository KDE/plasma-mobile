/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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

#ifndef COMPLETIONITEM_H
#define COMPLETIONITEM_H

#include <QObject>
#include <QImage>
#include <Nepomuk/Resource>

class CompletionItemPrivate;

class CompletionItem : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QImage preview READ preview WRITE setPreview NOTIFY previewChanged)
    Q_PROPERTY(QString iconName READ iconName WRITE setIconName NOTIFY iconNameChanged)

public:
    explicit CompletionItem(const QString &name = QString(),
             const QString &url = QString(),
             const QImage &i = QImage(),
             QObject *parent = 0 );
    CompletionItem(QObject *parent);
    //CompletionItem(Nepomuk::Resource resource, QObject *parent = 0);
    ~CompletionItem();
    void setResource(Nepomuk::Resource resource);

    QString name();
    QString iconName();
    QString url();
    QImage preview();
    QUrl resourceUri();

public Q_SLOTS:
    void setName(const QString &name);
    void setUrl(const QString &url);
    void setPreview(const QImage &image);
    void setIconName(const QString &iconName);

Q_SIGNALS:
    void nameChanged();
    void urlChanged();
    void previewChanged();
    void iconNameChanged();

private:
    CompletionItemPrivate* d;

};

#endif // COMPLETIONITEM_H
