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
#include <qwebview.h>
#include <qmap.h>
#include <qaction.h>


#include <KActionCollection>
#include <KMainWindow>
#include <KPluginInfo>

class KMainWindow;
class QProgressBar;
class QSignalMapper;
class Page;
class ScriptApi;
class RekonqActive;

/** Per-website data */
struct WebsiteOptions
{
    QString name;
    QString comment;
    int rating;
    QUrl startUrl;
    QIcon windowIcon;
    QString windowTitle;
};

class View : public QDeclarativeView
{
    Q_OBJECT

public:
    View( KMainWindow *win, QWidget *parent = 0 );
    ~View();

    WebsiteOptions* options() const;
    QString name() const;

private:
    WebsiteOptions *m_options;
};

#endif // VIEW_H
