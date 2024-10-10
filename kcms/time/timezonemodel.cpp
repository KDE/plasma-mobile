/*
    SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2014 Martin Klapetek <mklapetek@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "timezonemodel.h"
#include "timezonesi18n.h"

#include <KLocalizedString>
#include <QStringMatcher>
#include <QTimeZone>

TimeZoneFilterProxy::TimeZoneFilterProxy(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    m_stringMatcher.setCaseSensitivity(Qt::CaseInsensitive);
}

bool TimeZoneFilterProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (!sourceModel() || m_filterString.isEmpty()) {
        return true;
    }

    const QString city = sourceModel()->index(source_row, 0, source_parent).data(TimeZoneModel::CityRole).toString();
    const QString region = sourceModel()->index(source_row, 0, source_parent).data(TimeZoneModel::RegionRole).toString();
    const QString comment = sourceModel()->index(source_row, 0, source_parent).data(TimeZoneModel::CommentRole).toString();

    if (m_stringMatcher.indexIn(city) != -1 || m_stringMatcher.indexIn(region) != -1 || m_stringMatcher.indexIn(comment) != -1) {
        return true;
    }

    return false;
}

void TimeZoneFilterProxy::setFilterString(const QString &filterString)
{
    m_filterString = filterString;
    m_stringMatcher.setPattern(filterString);
    emit filterStringChanged();
    invalidateFilter();
}

//=============================================================================

TimeZoneModel::TimeZoneModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_timezonesI18n(new TimezonesI18n(this))
{
    update();
}

TimeZoneModel::~TimeZoneModel()
{
}

int TimeZoneModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_data.count();
}

QVariant TimeZoneModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid));

    const TimeZoneData &currentData = m_data.at(index.row());

    switch (role) {
    case TimeZoneIdRole:
        return currentData.id;
    case RegionRole: {
        return currentData.region;
    case CityRole:
        if (currentData.city.isEmpty())
            return currentData.id;
    }
        return currentData.city;
    case CommentRole:
        return currentData.comment;
    case CheckedRole:
        return currentData.checked;
    }

    return {};
}

bool TimeZoneModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || value.isNull()) {
        return false;
    }

    if (role == CheckedRole) {
        m_data[index.row()].checked = value.toBool();
        emit dataChanged(index, index);

        if (m_data[index.row()].checked) {
            m_selectedTimeZones.append(m_data[index.row()].id);
            m_offsetData.insert(m_data[index.row()].id, m_data[index.row()].offsetFromUtc);
        } else {
            m_selectedTimeZones.removeAll(m_data[index.row()].id);
            m_offsetData.remove(m_data[index.row()].id);
        }

        sortTimeZones();

        emit selectedTimeZonesChanged();
        return true;
    }

    return false;
}

void TimeZoneModel::update()
{
    beginResetModel();
    m_data.clear();

    QStringList cities;
    QHash<QString, QTimeZone> zonesByCity;

    const auto systemTimeZones = QTimeZone::availableTimeZoneIds();

    for (const auto &id : systemTimeZones) {
        const QTimeZone zone(id);

        const QStringList splitted = QString::fromUtf8(id).split(QStringLiteral("/"));

        // CITY | COUNTRY | CONTINENT
        const QString key = QStringLiteral("%1|%2|%3").arg(splitted.last(), QLocale::territoryToString(zone.territory()), splitted.first());

        cities.append(key);
        zonesByCity.insert(key, zone);
    }
    cities.sort(Qt::CaseInsensitive);

    for (const QString &key : std::as_const(cities)) {
        const QTimeZone timeZone = zonesByCity.value(key);
        QString comment = timeZone.comment();

        const QStringList cityCountryContinent = key.split(QLatin1Char('|'));

        TimeZoneData newData;
        newData.id = timeZone.id();
        newData.region = timeZone.territory() == QLocale::AnyCountry
            ? QString()
            : m_timezonesI18n->i18nContinents(cityCountryContinent.at(2)) + QLatin1Char('/') + m_timezonesI18n->i18nCountry(timeZone.territory());
        newData.city = m_timezonesI18n->i18nCity(cityCountryContinent.at(0));
        newData.comment = comment;
        newData.checked = false;
        newData.offsetFromUtc = timeZone.offsetFromUtc(QDateTime::currentDateTimeUtc());
        m_data.append(newData);
    }

    endResetModel();
}

void TimeZoneModel::setSelectedTimeZones(const QStringList &selectedTimeZones)
{
    m_selectedTimeZones = selectedTimeZones;
    for (int i = 0; i < m_data.size(); i++) {
        if (m_selectedTimeZones.contains(m_data.at(i).id)) {
            m_data[i].checked = true;
            m_offsetData.insert(m_data[i].id, m_data[i].offsetFromUtc);

            QModelIndex index = createIndex(i, 0);
            emit dataChanged(index, index);
        }
    }

    sortTimeZones();
}

void TimeZoneModel::selectLocalTimeZone()
{
    m_data[0].checked = true;

    QModelIndex index = createIndex(0, 0);
    emit dataChanged(index, index);

    m_selectedTimeZones << m_data[0].id;
    emit selectedTimeZonesChanged();
}

QHash<int, QByteArray> TimeZoneModel::roleNames() const
{
    return QHash<int, QByteArray>({
        {TimeZoneIdRole, "timeZoneId"},
        {RegionRole, "region"},
        {CityRole, "city"},
        {CommentRole, "comment"},
        {CheckedRole, "checked"},
    });
}

void TimeZoneModel::sortTimeZones()
{
    std::sort(m_selectedTimeZones.begin(), m_selectedTimeZones.end(), [this](const QString &a, const QString &b) {
        return m_offsetData.value(a) < m_offsetData.value(b);
    });
}
