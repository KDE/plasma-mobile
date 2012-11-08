/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "basicqueryprovider.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QDBusConnectionInterface>
#include <QTimer>

#include <KDebug>
#include <KMimeType>

#include <Nepomuk2/ResourceManager>

BasicQueryProvider::BasicQueryProvider(QObject *parent)
    : QObject(parent),
      m_minimumRating(0),
      m_maximumRating(0)
{
    m_queryTimer = new QTimer(this);
    m_queryTimer->setInterval(0);
    m_queryTimer->setSingleShot(true);
    connect(m_queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));

    m_extraParameters = new QDeclarativePropertyMap;
    connect (m_extraParameters, SIGNAL(valueChanged(QString,QVariant)), m_queryTimer, SLOT(start()));
}

BasicQueryProvider::~BasicQueryProvider()
{
    delete m_extraParameters;
}


void BasicQueryProvider::setQuery(const Nepomuk2::Query::Query &query)
{
    m_query = query;

    emit queryChanged();
}

Nepomuk2::Query::Query BasicQueryProvider::query() const
{
    return m_query;
}

void BasicQueryProvider::setResourceType(const QString &type)
{
    if (m_resourceType == type) {
        return;
    }

    m_resourceType = type;
    m_queryTimer->start();
    emit resourceTypeChanged();
}

QString BasicQueryProvider::resourceType() const
{
    return m_resourceType;
}

void BasicQueryProvider::setMimeTypesList(const QVariantList &types)
{
    //FIXME: not exactly efficient
    QStringList stringList = variantToStringList(types);

    if (m_mimeTypes == stringList) {
        return;
    }

    m_mimeTypes = stringList;
    m_queryTimer->start();
    emit mimeTypesChanged();
}

QVariantList BasicQueryProvider::mimeTypesList() const
{
    return stringToVariantList(m_mimeTypes);
}

void BasicQueryProvider::setActivityId(const QString &activityId)
{
    if (m_activityId == activityId) {
        return;
    }

    m_activityId = activityId;
    m_queryTimer->start();
    emit activityIdChanged();
}

QString BasicQueryProvider::activityId() const
{
    return m_activityId;
}

void BasicQueryProvider::setTags(const QVariantList &tags)
{
    //FIXME: not exactly efficient
    QStringList stringList = variantToStringList(tags);

    if (m_tags == stringList) {
        return;
    }

    m_tags = stringList;
    m_queryTimer->start();
    emit tagsChanged();
}

QVariantList BasicQueryProvider::tags() const
{
    return stringToVariantList(m_tags);
}

QStringList BasicQueryProvider::tagStrings() const
{
    return m_tags;
}

QStringList BasicQueryProvider::mimeTypeStrings() const
{
    return m_mimeTypes;
}

void BasicQueryProvider::requestRefresh()
{
    m_queryTimer->start();
}

void BasicQueryProvider::setStartDateString(const QString &date)
{
    QDate newDate = QDate::fromString(date, "yyyy-MM-dd");

    if (m_startDate == newDate) {
        return;
    }

    m_startDate = newDate;
    m_queryTimer->start();
    emit startDateChanged();
}

QString BasicQueryProvider::startDateString() const
{
    return m_startDate.toString("yyyy-MM-dd");
}

void BasicQueryProvider::setEndDateString(const QString &date)
{
    QDate newDate = QDate::fromString(date, "yyyy-MM-dd");

    if (m_endDate == newDate) {
        return;
    }

    m_endDate = newDate;
    m_queryTimer->start();
    emit endDateChanged();
}

QString BasicQueryProvider::endDateString() const
{
    return m_endDate.toString("yyyy-MM-dd");
}

void BasicQueryProvider::setStartDate(const QDate &date)
{
    if (m_startDate == date) {
        return;
    }

    m_startDate = date;
    m_queryTimer->start();
    emit startDateChanged();
}

QDate BasicQueryProvider::startDate() const
{
    return m_startDate;
}

void BasicQueryProvider::setEndDate(const QDate &date)
{
    if (m_endDate == date) {
        return;
    }

    m_endDate = date;
    m_queryTimer->start();
    emit endDateChanged();
}

QDate BasicQueryProvider::endDate() const
{
    return m_endDate;
}

void BasicQueryProvider::setMinimumRating(int rating)
{
    if (m_minimumRating == rating) {
        return;
    }

    m_minimumRating = rating;
    m_queryTimer->start();
    emit minimumRatingChanged();
}

int BasicQueryProvider::minimumRating() const
{
    return m_minimumRating;
}

void BasicQueryProvider::setMaximumRating(int rating)
{
    if (m_maximumRating == rating) {
        return;
    }

    m_maximumRating = rating;
    m_queryTimer->start();
    emit maximumRatingChanged();
}

int BasicQueryProvider::maximumRating() const
{
    return m_maximumRating;
}

QObject *BasicQueryProvider::extraParameters() const
{
    return m_extraParameters;
}

void BasicQueryProvider::doQuery()
{
    //Abstract, implement in subclasses
}

#include "basicqueryprovider.moc"
