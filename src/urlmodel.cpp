/***************************************************************************
 *                                                                         *
 *   Copyright 2014 Sebastian Kügler <sebas@kde.org>                       *
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
#include <QDir>
#include <QFile>
#include <QFileInfo>
//#include <QIcon>
#include <QStandardPaths>

#include <QJsonArray>
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

    m_fakeData = fakeData();

    setSourceData(&m_fakeData);

    save();
}

void UrlModel::setSourceData(UrlData *data)
{
    if (m_data != data) {
        m_data = data;
        //modelReset(); ??
    }
}

QHash<int, QByteArray> UrlModel::roleNames() const
{
    return m_roleNames;
}

int UrlModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    if (m_data->size() <= 0) {
        return 0;
    } else {
        return m_data->size();
    }
}

QVariant UrlModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {

        Url currentData = m_data->at(index.row());

        switch (role) {
        case lastVisited:
            return QDateTime::fromString(currentData.value(key(role)).toString());
        }
        return currentData.value(key(role));
    }
    return QVariant();
}

void UrlModel::update()
{
    if (m_data->size() <= 0) {
        return;
    }
}

bool UrlModel::load()
{


    return true;
}

bool UrlModel::save()
{
    qDebug() << "Saving bookmarks to " << m_fileName;
    QVariantMap vm;
    QVariantMap urlsVm;
    vm[QStringLiteral("Version")] = QStringLiteral("1.0");
    vm[QStringLiteral("Timestamp")] = QDateTime::currentMSecsSinceEpoch();

    QJsonArray urls;

    Q_FOREACH (auto url, m_fakeData) {
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
    } else {
        if (!dir.mkpath(".")) {
            qDebug() << "Destdir doesn't exist and I can't create it: " << destdir;
            return false;
        }
    }

    qDebug() << "urls : " << jdoc.toJson();
    qDebug() << "Writing to: " << destfile;

    QFile file(destfile);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Failed to open " << destfile;
        return false;
    }

    file.write(jdoc.toJson());
//     file.write(jdoc.toBinaryData());
    qWarning() << "Wrote " << destfile << " (" << urls.count() << " urls)";

    return true;
}

QString UrlModel::key(int role) const
{
    return QString::fromLocal8Bit(m_roleNames[role]);
}


UrlData UrlModel::fakeData()
{
    UrlData data;
    {
        Url u;
        u.insert(key(url), QStringLiteral("http://m.nos.nl"));
        u.insert(key(title), QStringLiteral("Nieuws"));
        u.insert(key(icon), QStringLiteral("text-html"));
        u.insert(key(bookmarked), true);
        u.insert(key(lastVisited), QDateTime::currentDateTime().toString());
        data << u;
    }
    {
        Url u;
        u.insert(key(url), QStringLiteral("http://vizZzion.org"));
        u.insert(key(title), QStringLiteral("sebas' blog"));
        u.insert(key(icon), QStringLiteral("/home/sebas/Pictures/avatar-small.jpg"));
        u.insert(key(preview), QStringLiteral("/home/sebas/Pictures/avatar-small.jpg"));
        u.insert(key(bookmarked), true);
        u.insert(key(lastVisited), QDateTime::currentDateTime().toString());
        data << u;
    }
    {
        Url u;
        u.insert(key(url), QStringLiteral("http://lwn.net"));
        u.insert(key(title), QStringLiteral("Linux Weekly News"));
        u.insert(key(icon), QStringLiteral("text-html"));
        u.insert(key(bookmarked), true);
        u.insert(key(lastVisited), QDateTime::currentDateTime().toString());
        data << u;
    }
    {
        Url u;
        u.insert(key(url), QStringLiteral("http://tweakers.net"));
        u.insert(key(title), QStringLiteral("Tweakers.net"));
        u.insert(key(icon), QStringLiteral("text-html"));
        u.insert(key(bookmarked), true);
        u.insert(key(lastVisited), QDateTime::currentDateTime().toString());
        data << u;
    }
    {
        Url u;
        u.insert(key(url), QStringLiteral("http://en.wikipedia.org"));
        u.insert(key(title), QStringLiteral("Wikipedia"));
        u.insert(key(icon), QStringLiteral("text-html"));
        //u.insert(key(preview), QStringLiteral("/home/sebas/Pictures/avatar-small.jpg"));
        u.insert(key(bookmarked), false);
        u.insert(key(lastVisited), QDateTime::currentDateTime().toString());
        data << u;
    }
    {
        Url u;
        u.insert(key(url), QStringLiteral("http://plasma-mobile.org"));
        u.insert(key(title), QStringLiteral("Plasma Mobile"));
        u.insert(key(icon), QStringLiteral("plasma"));
        u.insert(key(bookmarked), true);
        u.insert(key(lastVisited), QDateTime::currentDateTime().toString());
        data << u;
    }

    return data;
}

