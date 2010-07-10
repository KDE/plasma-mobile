/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2009 Marco Martin <notmart@gmail.com>                   *
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

#ifndef DBUSSYSTEMTRAYTASK_H
#define DBUSSYSTEMTRAYTASK_H

#include "../../core/task.h"

#include <Plasma/DataEngine>

namespace Plasma
{

class Service;

}

namespace SystemTray
{

class DBusSystemTrayTaskPrivate;

class DBusSystemTrayTask : public Task
{
    Q_OBJECT

    friend class DBusSystemTrayProtocol;

public:
    DBusSystemTrayTask(const QString &serviceName, Plasma::Service *service, QObject *parent);
    ~DBusSystemTrayTask();

    QGraphicsWidget* createWidget(Plasma::Applet *host);
    bool isValid() const;
    bool isEmbeddable() const;
    virtual QString name() const;
    virtual QString typeId() const;
    virtual QIcon icon() const;

private:
    void syncToolTip(const QString &title, const QString &subTitle, const QIcon &toolTipIcon);
    void syncMovie(const QString &);
    void syncIcons(const Plasma::DataEngine::Data &properties);

private Q_SLOTS:
    void syncStatus(QString status);
    void updateMovieFrame();
    void blinkAttention();
    void dataUpdated(const QString &taskName, const Plasma::DataEngine::Data &taskData);

private:
    QString m_typeId;
    QString m_name;
    QString m_title;
    QIcon m_icon;
    QString m_iconName;
    QIcon m_attentionIcon;
    QString m_attentionIconName;
    QMovie *m_movie;
    QTimer *m_blinkTimer;
    Plasma::Service *m_service;
    bool m_blink : 1;
    bool m_valid : 1;
    bool m_embeddable : 1;
};

}


#endif
