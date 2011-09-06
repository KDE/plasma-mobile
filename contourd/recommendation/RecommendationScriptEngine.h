/*
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


#ifndef RECOMMENDATIONSCRIPTENGINE_H_
#define RECOMMENDATIONSCRIPTENGINE_H_

#include "RecommendationEngine.h"

#include <QScriptValue>

namespace Contour {

/**
 *
 */
class RecommendationScriptEngine: public RecommendationEngine {
    Q_OBJECT
public:
    RecommendationScriptEngine(QObject * parent, const QString & script);
    virtual ~RecommendationScriptEngine();

    virtual void init();
    virtual void activate(const QString & id, const QString & action = QString());

Q_SIGNALS:
    // note that you need to pass sorted items to
    // this method (sorted by the score)
    void recommendationsUpdated(const QList<Contour::RecommendationItem> & recommendations);

    void activationRequested(const QString & id, const QString & action);

public Q_SLOTS:
    // TODO: These could be removed to some plugins or whatever
    QScriptValue getSensor(const QString & sensor);
    QScriptValue getTimer(int msec);
    void openUrl(const QString & url);

public Q_SLOTS:
    void addRecommendation(
            double score,
            const QString & id,
            const QString & title,
            const QString & description,
            const QString & icon
        );

    void removeRecommendation(const QString & id);
    void removeRecommendations();

private Q_SLOTS:
    void signalHandlerException(const QScriptValue & exception);
    void delayedUpdateNotification();
    void sendUpdateNotification();

private:
    class Private;
    Private * const d;
};

} // namespace Contour

#endif // RECOMMENDATIONSCRIPTENGINE_H_

