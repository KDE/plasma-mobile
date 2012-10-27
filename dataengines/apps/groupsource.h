/*
 * Copyright 2009 Chani Armitage <chani@kde.org>
 * Copyright 2011 Marco Martin <mart@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef GROUPSOURCE_H
#define GROUPSOURCE_H

// plasma
#include <Plasma/DataContainer>

#include <KService>
#include <KServiceGroup>

/**
 * App group Source
 */
class GroupSource : public Plasma::DataContainer
{
    Q_OBJECT

public:
    explicit GroupSource(const QString &name, QObject *parent = 0);
    ~GroupSource();

protected:
    Plasma::Service *createService();
    void populate();
    void loadGroup(KServiceGroup::Ptr group);

private Q_SLOTS:
    void sycocaChanged(const QStringList &changes);

private:
    QString m_group;
};

#endif // GROUPSOURCE_H
