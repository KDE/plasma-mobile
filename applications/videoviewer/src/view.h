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
class QDeclarativeItem;
class QProgressBar;
class QSignalMapper;
class Page;
class ScriptApi;
class VideoViewer;


namespace Plasma
{
    class Package;
}

class AppView : public QDeclarativeView
{
    Q_OBJECT

public:
    AppView(const QString &url, QWidget *parent = 0 );
    ~AppView();

    QString name() const;

    void setUseGL(const bool on);
    bool useGL() const;

private Q_SLOTS:
    void onStatusChanged(QDeclarativeView::Status status);

private:
    QDeclarativeItem* m_videoViewer;
    Plasma::Package *m_package;
    bool m_useGL;
};

#endif // VIEW_H
