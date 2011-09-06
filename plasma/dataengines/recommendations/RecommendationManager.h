/*
 *   Copyright (C) 2011 Marco Martin <mart@kde.org>
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#ifndef RECOMMENDATIONMANAGER_H_
#define RECOMMENDATIONMANAGER_H_

#include "RecommendationItem.h"

#include <QDBusMessage>

namespace Contour {

class RecommendationManager: public QObject {
    Q_OBJECT
public:
    // TODO: Refcount instead of singleton
    static RecommendationManager * self();

Q_SIGNALS:
    void recommendationsChanged(const QList<Contour::RecommendationItem> &recommendations);

private Q_SLOTS:
    void updateRecommendations();
    void updateRecommendationsFinished(const QDBusMessage & message);

public Q_SLOTS:
    void executeAction(const QString & engine, const QString & id, const QString & action);

private:
    RecommendationManager();
    ~RecommendationManager();

    static RecommendationManager * s_instance;

    class Private;
    Private * const d;
};

} // namespace Contour

#endif // RECOMMENDATIONMANAGER_H_

