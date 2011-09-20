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

#ifndef RECOMMENDATION_ENGINE_H_
#define RECOMMENDATION_ENGINE_H_

#include <kdemacros.h>
#include <KPluginFactory>
#include <KPluginLoader>

#include "RecommendationItem.h"

#define RECOMMENDATION_EXPORT_PLUGIN(ClassName, AboutData)                       \
    K_PLUGIN_FACTORY(ClassName##Factory, registerPlugin<ClassName>();) \
    K_EXPORT_PLUGIN(ClassName##Factory("AboutData"))


namespace Contour {

/**
 *
 */
class KDE_EXPORT RecommendationEngine: public QObject {
    Q_OBJECT

public:
    RecommendationEngine(QObject * parent);
    virtual ~RecommendationEngine();

    virtual void init();
    virtual void activate(const QString & id, const QString & action = QString());
    virtual QString name() const;

    KConfigGroup * config() const;

Q_SIGNALS:
    // note that you need to pass sorted items to
    // this method
    void recommendationsUpdated(const QList<Contour::RecommendationItem> & recommendations);

private:
    class Private;
    Private * const d;
};


} // namespace Contour

#endif // RECOMMENDATION_ENGINE_H_
