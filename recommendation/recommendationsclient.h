/*
 *   Copyright (C) 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef RECOMMENDATIONSCLIENT_H
#define RECOMMENDATIONSCLIENT_H

#include <QObject>

#include "recommendationsclient_export.h"


class QDBusPendingCallWatcher;

namespace Contour {

class Recommendation;
class RecommendationsClientPrivate;

class RECOMMENDATIONSCLIENT_EXPORT RecommendationsClient : public QObject
{
    Q_OBJECT
    //Q_PROPERTY(QList<Contour::Recommendation*> recommendations READ recommendations NOTIFY recommendationsChanged)

public:
    RecommendationsClient(QObject* parent);
    ~RecommendationsClient();

    QList<Contour::Recommendation*> recommendations() const;

Q_SIGNALS:
    void recommendationsChanged(const QList<Contour::Recommendation*> &);

private:
    RecommendationsClientPrivate *const d;

    friend class RecommendationsClientPrivate;
    Q_PRIVATE_SLOT(d, void recommendationsCallback(QDBusPendingCallWatcher *call))
    Q_PRIVATE_SLOT(d, void updateRecommendations(const QList<Contour::Recommendation*> &recommendations))
};

}

#endif
