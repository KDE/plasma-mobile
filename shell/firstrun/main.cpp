/***************************************************************************
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                      *
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

#include <KApplication>
#include <KAboutData>
#include <KCmdLineArgs>
#include <KLocale>
#include <KIcon>
#include <kdebug.h>

#include "app.h"

static const char description[] = I18N_NOOP( "Plasma Active first run to setup Activities and Resources" );
static const char version[] = "0.1";

int main(int argc, char **argv)
{
    kDebug() << "First run running ...";
    App app(argc, argv);
    int rc = app.exec();
    return rc;
}

