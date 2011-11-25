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

#ifndef DOCUMENTS_P_H_
#define DOCUMENTS_P_H_

#include "Documents.h"
#include "RecommendationItem.h"

#include <Activities/Consumer>

class DocumentsEnginePrivate: public QObject {
    Q_OBJECT

public:
    DocumentsEnginePrivate(DocumentsEngine * parent);
    ~DocumentsEnginePrivate();

public Q_SLOTS:
    void updated(const QVariantList & data);
    void removeRecommendation(const QString & id);

    void inserted(int position, const QVariantList & item);
    void removed(int position);
    void changed(int position, const QVariantList & item);

    void serviceOffline();
    void serviceOnline();

public:
    QList<Contour::RecommendationItem> recommendations;
    DocumentsEngine * const q;

    Activities::Consumer * activitymanager;

};


#endif // DOCUMENTS_P_H_

