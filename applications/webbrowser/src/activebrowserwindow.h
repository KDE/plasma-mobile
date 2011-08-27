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


#ifndef ACTIVEBROWSERWINDOW_H
#define ACTIVEBROWSERWINDOW_H

#include <QMainWindow>

class View;

/**
 * This class serves as the main window for the Active Webbrowser.
 *
 * @short Active Webbrowser main window class
 * @author Sebastian Kügler <sebas@kde.org>
 * @version 0.1
 */
class ActiveBrowserWindow : public QMainWindow
{
    Q_OBJECT
public:
    ActiveBrowserWindow(const QString &url, QWidget *parent = 0);
    virtual ~ActiveBrowserWindow();
    QString name();
    QIcon icon();

    void setUseGL(const bool on);
    bool useGL() const;

Q_SIGNALS:
    void newWindow(const QString &url);

protected Q_SLOTS:
    void setCaption(const QString &caption);

protected:
    void closeEvent(QCloseEvent *);

private:
    View *m_widget;
};

#endif // REKONQACTIVE_H
