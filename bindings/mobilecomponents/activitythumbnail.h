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

#ifndef ACTIVITYTHUMBNAIL_H
#define ACTIVITYTHUMBNAIL_H

#include <QObject>

//FIXME: kstandarddirs should just be binded in qml
class ActivityThumbnail : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString activityId READ activityId WRITE setActivityId)
    Q_PROPERTY(QString thumbnailPath READ thumbnailPath NOTIFY thumbnailPathChanged)

public:
    ActivityThumbnail(QObject *parent = 0);
    ~ActivityThumbnail();

    QString activityId() const;
    void setActivityId(const Qstring &activityId);

    QString const thumbnailPath();

Q_SIGNALS:
    void activityIdChanged();
    void thumbnailPathChanged();

private:
    QString m_activityId;
};

#endif
