/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
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


#ifndef ACTIVESETTINGS_H
#define ACTIVESETTINGS_H

#include <KApplication>

class KCmdLineArgs;

/**
 * This class serves as the main application for the Active Webbrowser.
 *
 * @short Active Webbrowser browser application class, managing browser windows
 * @author Sebastian Kügler <sebas@kde.org>
 * @version 0.1
 */
class ActiveSettings : public KApplication
{
    Q_OBJECT
public:
    ActiveSettings(const KCmdLineArgs *args);
    virtual ~ActiveSettings();

public Q_SLOTS:
    void newWindow(const QString &module);

};

#endif // ACTIVESETTINGS_H
