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


#ifndef ACTIVESETTINGSWINDOW_H
#define ACTIVESETTINGSWINDOW_H

#include <QMainWindow>

class View;

/**
 * This class serves as the main window for Active Settings.
 *
 * @short Active Settings main window class
 * @author Sebastian Kügler <sebas@kde.org>
 * @version 0.1
 */
class ActiveSettingsWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit ActiveSettingsWindow(const QString &url, QWidget *parent = 0);
    virtual ~ActiveSettingsWindow();
    QString name();
    QIcon icon();

    View* view();

protected:
    void closeEvent(QCloseEvent *);

private:
    View *m_widget;
};

#endif // ACTIVESETTINGSWINDOW_H
