/*
    Copyright (C) 2012  Marco Martin <mart@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/


#ifndef TIMELINEQUERYPROVIDER_H
#define TIMELINEQUERYPROVIDER_H

#include "basicqueryprovider.h"

class TimelineQueryProviderPrivate;

class TimelineQueryProvider : public BasicQueryProvider
{
    Q_OBJECT
    /**
     * @property Level The level of the categorization, may be Year, Month or Day
     */
    Q_PROPERTY(Level level READ level WRITE setLevel NOTIFY levelChanged)

    /**
     * @property string An user-readable description of the results shown, such as "All years", "Year 2011" or "March 2007"
     */
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)

public:
    /**
     * @enum Level the detail of the categorization: show years, months or days
     */
    enum Level {
        Year = 0,
        Month,
        Day
    };
    Q_ENUMS(Level)

    enum Roles {
        LabelRole = Qt::UserRole + 1,
        YearRole = Qt::UserRole + 2,
        MonthRole = Qt::UserRole + 3,
        DayRole = Qt::UserRole + 4,
        CountRole = Qt::UserRole + 5
    };

    TimelineQueryProvider(QObject* parent = 0);
    ~TimelineQueryProvider();

    virtual QVariant formatData(const Nepomuk2::Query::Result &row, const QPersistentModelIndex &index, int role) const;

    void setLevel(Level level);
    Level level() const;

    QString description() const;

Q_SIGNALS:
    void levelChanged();
    void descriptionChanged();

protected:
    virtual void doQuery();

private:
    TimelineQueryProviderPrivate *const d;
};

#endif // TIMELINEQUERYPROVIDER_H
