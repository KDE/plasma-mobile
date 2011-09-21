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

#ifndef RECOMMENDATIONSCRIPTENGINE_P_H_
#define RECOMMENDATIONSCRIPTENGINE_P_H_

#include <QScriptValue>
#include <KConfigGroup>
#include <QTimer>

#include "RecommendationScriptEngine.h"

namespace Contour {

/**
 *
 */
class RecommendationScriptEngineConfig: public QObject {
    Q_OBJECT

public:
    RecommendationScriptEngineConfig(QObject * parent, KConfigGroup * config);
    virtual ~RecommendationScriptEngineConfig();

    Q_INVOKABLE bool BoolValue(const QString & field, bool defaultValue) const;
    Q_INVOKABLE void SetBoolValue(const QString & field, bool newValue) const;

    Q_INVOKABLE int IntValue(const QString & field, int defaultValue) const;
    Q_INVOKABLE void SetIntValue(const QString & field, int newValue) const;

    Q_INVOKABLE QString StringValue(const QString & field, QString defaultValue) const;
    Q_INVOKABLE void SetStringValue(const QString & field, QString newValue) const;

    Q_INVOKABLE QStringList StringListValue(const QString & field, QStringList defaultValue) const;
    Q_INVOKABLE void SetStringListValue(const QString & field, QStringList newValue) const;

private:
    KConfigGroup * m_config;
};

class RecommendationScriptEngine::Private {
public:
    Private()
        : autoremove(true)
    {
    }

    ~Private()
    {
    }

    QScriptEngine * engine;

    QList<RecommendationItem> recommendations;
    QString script;
    QTimer delay;

    bool autoremove;

};


} // namespace Contour

#endif // RECOMMENDATIONSCRIPTENGINE_P_H_

