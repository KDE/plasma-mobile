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
#include <QDBusConnectionInterface>
#include <QTimer>

#include <KDebug>
#include <KMimeType>

#include <Nepomuk2/ResourceManager>


class BasicQueryProviderPrivate
{
public:
    BasicQueryProviderPrivate(BasicQueryProvider *provider)
        : q(provider),
          minimumRating(0),
          maximumRating(0)
    {
        queryTimer = new QTimer(q);
        queryTimer->setInterval(0);
        queryTimer->setSingleShot(true);
        QObject::connect(queryTimer, SIGNAL(timeout()), q, SLOT(doQuery()));

        extraParameters = new QDeclarativePropertyMap;
        QObject::connect (extraParameters, SIGNAL(valueChanged(QString,QVariant)), queryTimer, SLOT(start()));
    }

    BasicQueryProvider *q;
    QTimer *queryTimer;

    QString resourceType;
    QStringList mimeTypes;
    QString activityId;
    QStringList tags;
    QDate startDate;
    QDate endDate;
    int minimumRating;
    int maximumRating;
    QDeclarativePropertyMap *extraParameters;
};

BasicQueryProvider::BasicQueryProvider(QObject *parent)
    : AbstractQueryProvider(parent),
      d(new BasicQueryProviderPrivate(this))
{
    
}

BasicQueryProvider::~BasicQueryProvider()
{
    delete d->extraParameters;
}

void BasicQueryProvider::setResourceType(const QString &type)
{
    if (d->resourceType == type) {
        return;
    }

    d->resourceType = type;
    d->queryTimer->start();
    emit resourceTypeChanged();
}

QString BasicQueryProvider::resourceType() const
{
    return d->resourceType;
}

void BasicQueryProvider::setMimeTypesList(const QVariantList &types)
{
    //FIXME: not exactly efficient
    QStringList stringList = variantToStringList(types);

    if (d->mimeTypes == stringList) {
        return;
    }

    d->mimeTypes = stringList;
    d->queryTimer->start();
    emit mimeTypesChanged();
}

QVariantList BasicQueryProvider::mimeTypesList() const
{
    return stringToVariantList(d->mimeTypes);
}

void BasicQueryProvider::setActivityId(const QString &activityId)
{
    if (d->activityId == activityId) {
        return;
    }

    d->activityId = activityId;
    d->queryTimer->start();
    emit activityIdChanged();
}

QString BasicQueryProvider::activityId() const
{
    return d->activityId;
}

void BasicQueryProvider::setTags(const QVariantList &tags)
{
    //FIXME: not exactly efficient
    QStringList stringList = variantToStringList(tags);

    if (d->tags == stringList) {
        return;
    }

    d->tags = stringList;
    d->queryTimer->start();
    emit tagsChanged();
}

QVariantList BasicQueryProvider::tags() const
{
    return stringToVariantList(d->tags);
}

QStringList BasicQueryProvider::tagStrings() const
{
    return d->tags;
}

QStringList BasicQueryProvider::mimeTypeStrings() const
{
    return d->mimeTypes;
}

void BasicQueryProvider::requestRefresh()
{
    d->queryTimer->start();
}

void BasicQueryProvider::setStartDateString(const QString &date)
{
    QDate newDate = QDate::fromString(date, "yyyy-MM-dd");

    if (d->startDate == newDate) {
        return;
    }

    d->startDate = newDate;
    d->queryTimer->start();
    emit startDateChanged();
}

QString BasicQueryProvider::startDateString() const
{
    return d->startDate.toString("yyyy-MM-dd");
}

void BasicQueryProvider::setEndDateString(const QString &date)
{
    QDate newDate = QDate::fromString(date, "yyyy-MM-dd");

    if (d->endDate == newDate) {
        return;
    }

    d->endDate = newDate;
    d->queryTimer->start();
    emit endDateChanged();
}

QString BasicQueryProvider::endDateString() const
{
    return d->endDate.toString("yyyy-MM-dd");
}

void BasicQueryProvider::setStartDate(const QDate &date)
{
    if (d->startDate == date) {
        return;
    }

    d->startDate = date;
    d->queryTimer->start();
    emit startDateChanged();
}

QDate BasicQueryProvider::startDate() const
{
    return d->startDate;
}

void BasicQueryProvider::setEndDate(const QDate &date)
{
    if (d->endDate == date) {
        return;
    }

    d->endDate = date;
    d->queryTimer->start();
    emit endDateChanged();
}

QDate BasicQueryProvider::endDate() const
{
    return d->endDate;
}

void BasicQueryProvider::setMinimumRating(int rating)
{
    if (d->minimumRating == rating) {
        return;
    }

    d->minimumRating = rating;
    d->queryTimer->start();
    emit minimumRatingChanged();
}

int BasicQueryProvider::minimumRating() const
{
    return d->minimumRating;
}

void BasicQueryProvider::setMaximumRating(int rating)
{
    if (d->maximumRating == rating) {
        return;
    }

    d->maximumRating = rating;
    d->queryTimer->start();
    emit maximumRatingChanged();
}

int BasicQueryProvider::maximumRating() const
{
    return d->maximumRating;
}

QObject *BasicQueryProvider::extraParameters() const
{
    return d->extraParameters;
}

void BasicQueryProvider::doQuery()
{
    //Abstract, implement in subclasses
}

#include "basicqueryprovider.moc"
