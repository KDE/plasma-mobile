/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                  *
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
 *                                                                         *
 ***************************************************************************/

#include "urlmodel.h"
#include <QDebug>
#include <QByteArray>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
//#include <QIcon>
#include <QStandardPaths>

#include <QJsonDocument>


using namespace AngelFish;

UrlModel::UrlModel(const QString &fileName, QObject *parent) :
    QAbstractListModel(parent),
    m_fileName(fileName)
{
    m_roleNames.insert(url, "url");
    m_roleNames.insert(title, "title");
    m_roleNames.insert(icon, "icon");
    m_roleNames.insert(preview, "preview");
    m_roleNames.insert(lastVisited, "lastVisited");
    m_roleNames.insert(bookmarked, "bookmarked");

    //m_fakeData = fakeData();

    //setSourceData(&m_fakeData);

    //save();
}

void UrlModel::setSourceData(QJsonArray &data)
{
    if (m_data != data) {
        m_data = data;
        //modelReset(); ??
    }
}

QJsonArray UrlModel::sourceData() const
{
    return m_data;
}

QHash<int, QByteArray> UrlModel::roleNames() const
{
    return m_roleNames;
}

int UrlModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    if (m_data.size() <= 0) {
        return 0;
    } else {
        return m_data.size();
    }
}

QVariant UrlModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {

        QJsonObject currentData = m_data.at(index.row()).toObject();

        switch (role) {
        case lastVisited:
            return QDateTime::fromString(currentData.value(key(role)).toString(), Qt::ISODate);
        case bookmarked:
            return currentData.value(key(role)).toBool();
        }
        if (currentData.value(key(role)).isUndefined()) {
            return QVariant();
        }
        return currentData.value(key(role)).toString();
    }
    return QVariant();
}

void UrlModel::update()
{
    // FIXME: Can we be more fine-grained, please?
    beginResetModel();
    endResetModel();
    //emit QAbstractItemModel::modelReset();
//     auto topleft = index(0);
//     auto bottomright = index(rowCount(topleft));
//     emit dataChanged(topleft, bottomright);
}

QString UrlModel::filePath() const
{
    QFileInfo fi(m_fileName);

    if (fi.isAbsolute()) {
        return m_fileName;
    }
    return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) \
                    + QStringLiteral("/angelfish/") \
                    + m_fileName;
}

bool UrlModel::load()
{

    QFile jsonFile(filePath());
    if (!jsonFile.exists()) {
        return false;
    }
    if (!jsonFile.open(QIODevice::ReadOnly)) {
        qDebug() << "Could not open" << m_fileName;
        return false;
    }
    //QJsonDocument jdoc = QJsonDocument::fromBinaryData(jsonFile.readAll());
    QJsonDocument jdoc = QJsonDocument::fromJson(jsonFile.readAll());
    jsonFile.close();


    qDebug() << "Loaded from file:" << jdoc.array().count() << filePath();
    QJsonArray plugins = jdoc.array();
    setSourceData(plugins);

    return true;
}

bool UrlModel::save()
{
    QVariantMap vm;
    QVariantMap urlsVm;
    vm[QStringLiteral("Version")] = QStringLiteral("1.0");
    vm[QStringLiteral("Timestamp")] = QDateTime::currentMSecsSinceEpoch();

    QJsonArray urls;

    Q_FOREACH (auto url, m_data) {
        urls << url;
    }

    QJsonDocument jdoc;
    jdoc.setArray(urls);

    QString destfile = m_fileName;
    QString destdir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QStringLiteral("/angelfish/");
    QDir dir(destdir);
    const QFileInfo fi(m_fileName);
    if (!fi.isAbsolute()) {
        destfile = destdir + m_fileName;
    }
    if (!dir.mkpath(".")) {
        qDebug() << "Destdir doesn't exist and I can't create it: " << destdir;
        return false;
    }

    QFile file(destfile);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Failed to open " << destfile;
        return false;
    }

    file.write(jdoc.toJson());
//     file.write(jdoc.toBinaryData());
    qWarning() << "Wrote " << destfile << " (" << urls.count() << " urls) ";// << jdoc.toJson();

    return true;
}

QString UrlModel::key(int role) const
{
    return QString::fromLocal8Bit(m_roleNames[role]);
}

void UrlModel::add(const QJsonObject &data)
{
    foreach (auto urldata, m_data) {
        if (urldata == data) {
            return;
        }
    }
    m_data.append(data);
    update();
}

void UrlModel::remove(const QString& url)
{
    for (int i = 0; i < m_data.count(); i++) {
        const QString u = m_data.at(i).toObject()[key(UrlModel::url)].toString();
        if (u == url) {
            m_data.removeAt(i);
            //int n = m_data.count();
            //qDebug() << "!!! Removed: " << url << " now" << m_data.count() << " was " << n;
            update();
            return;
        }
    }
}

