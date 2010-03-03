/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

#ifndef PLASMA_DESKTOP_H
#define PLASMA_DESKTOP_H

#include <Plasma/Containment>
#include <Plasma/QueryMatch>

namespace Plasma
{
    class RunnerManager;
}

class QDeclarativeEngine;
class QDeclarativeComponent;
class QStandardItemModel;

class MobileLauncher : public Plasma::Containment
{
    Q_OBJECT

public:
    MobileLauncher(QObject *parent, const QVariantList &args);
    ~MobileLauncher();
    void init();

    void constraintsEvent(Plasma::Constraints constraints);

public Q_SLOTS:
    void setQueryMatches(const QList<Plasma::QueryMatch> &m);

private:
    void errorPrint();
    void execute(const QString &fileName);
    void finishExecute();

    Plasma::RunnerManager *m_runnermg;

    QDeclarativeEngine* m_engine;
    QDeclarativeComponent* m_component;
    QObject *m_root;
    QStandardItemModel *m_runnerModel;

    bool m_loaded;

};

#endif // PLASMA_DESKTOP_H
