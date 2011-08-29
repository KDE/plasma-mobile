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

#ifndef VIEW_H
#define VIEW_H
#include <QDeclarativeView>

#include <KUrl>
#include <KIO/MetaData>

class QDeclarativeItem;
class QProgressBar;
class QSignalMapper;
class Page;
class ScriptApi;
class QNetworkRequest;

/** Per-website data */
struct WebsiteOptions
{
    QString title;
    QString url;
    QString mimetype;
    QString comment;
    int rating;
};

namespace Plasma
{
    class Package;
};
class CompletionModel;

class View : public QDeclarativeView
{
    Q_OBJECT

public:
    View(const QString &url, QWidget *parent = 0 );
    ~View();

    WebsiteOptions* options() const;
    QString name() const;

    void setUseGL(const bool on);
    bool useGL() const;

public Q_SLOTS:
    void setBookmarks();

Q_SIGNALS:
    void titleChanged(const QString&);
    void newWindow(const QString &url);

private:
    WebsiteOptions *m_options;
    QDeclarativeItem* m_webBrowser;
    QDeclarativeItem* m_urlInput;

private Q_SLOTS:
    void onStatusChanged(QDeclarativeView::Status status);
    void urlChanged();
    void urlFilterChanged();
    void onTitleChanged();
    void onUrlEntered(const QString&);

private:
    QString filterUrl(const QString &url);

    Plasma::Package *m_package;
    bool m_useGL;
    CompletionModel* m_completionModel;
};

#endif // VIEW_H
