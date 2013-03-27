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

#include "RecommendationEngine.h"

#include <KConfigGroup>
#include <KConfig>
#include <KDebug>

namespace Contour {

class RecommendationEngine::Private {
public:
    KConfig * mainConfig;
    KConfigGroup * engineConfig;
};

RecommendationEngine::RecommendationEngine(QObject * parent)
    : QObject(parent), d(new Private())
{
    d->mainConfig = NULL;
}

RecommendationEngine::~RecommendationEngine()
{
    delete d;
}

void RecommendationEngine::init()
{
    kDebug() << name();
}

void RecommendationEngine::activate(const QString & id, const QString & action)
{
    Q_UNUSED(id);
    Q_UNUSED(action);
}

KConfigGroup * RecommendationEngine::config() const
{
    if (!d->mainConfig) {
        d->mainConfig = new KConfig("contourrc");
        d->engineConfig = new KConfigGroup(d->mainConfig, "Engine-" + name());
    }

    return d->engineConfig;
}

} // namespace Contour
