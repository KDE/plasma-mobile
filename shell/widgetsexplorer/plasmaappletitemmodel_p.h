/*
 *   Copyright (C) 2007 Ivan Cukic <ivan.cukic+kde@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library/Lesser General Public License
 *   version 2, or (at your option) any later version, as published by the
 *   Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library/Lesser General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef PLASMA_PLASMAAPPLETITEMMODEL_P_H
#define PLASMA_PLASMAAPPLETITEMMODEL_P_H

#include <kplugininfo.h>
#include <Plasma/Applet>
#include "kcategorizeditemsviewmodels_p.h"

class PlasmaAppletItemModel;

/**
 * Implementation of the KCategorizedItemsViewModels::AbstractItem
 */
class PlasmaAppletItem : public QObject, public KCategorizedItemsViewModels::AbstractItem
{
    Q_OBJECT

public:
    enum FilterFlag {
        NoFilter = 0,
        Favorite = 1
    };

    Q_DECLARE_FLAGS(FilterFlags, FilterFlag)

    PlasmaAppletItem(PlasmaAppletItemModel *model, const KPluginInfo& info, FilterFlags flags = NoFilter);

    QString pluginName() const;
    QString name() const;
    QString category() const;
    QString description() const;
    QString license() const;
    QString website() const;
    QString version() const;
    QString author() const;
    QString email() const;

    int running() const;
    bool isLocal() const;
    void setFavorite(bool favorite);
    PlasmaAppletItemModel* appletItemModel();

    //set how many instances of this applet are running
    void setRunning(int count);
    bool passesFiltering(const KCategorizedItemsViewModels::Filter & filter) const;
    QVariantList arguments() const;
    QMimeData *mimeData() const;
    QStringList mimeTypes() const;

private:
    PlasmaAppletItemModel * m_model;
};

class PlasmaAppletItemModel : public QStandardItemModel
{
    Q_OBJECT

public:
    enum Roles {
        PluginNameRole = Qt::UserRole+1,
        DescriptionRole = Qt::UserRole+2,
        CategoryRole = Qt::UserRole+3,
        LicenseRole = Qt::UserRole+4,
        WebsiteRole = Qt::UserRole+5,
        VersionRole = Qt::UserRole+6,
        AuthorRole = Qt::UserRole+7,
        EmailRole = Qt::UserRole+8,
    };

    explicit PlasmaAppletItemModel(QObject * parent = 0);

    QStringList mimeTypes() const;
    QSet<QString> categories() const;

    QMimeData *mimeData(const QModelIndexList &indexes) const;

    void setFavorite(const QString &plugin, bool favorite);
    void setApplication(const QString &app);
    void setRunningApplets(const QHash<QString, int> &apps);
    void setRunningApplets(const QString &name, int count);

    QString &Application();

private:
    QString m_application;
    QStringList m_favorites;
    KConfigGroup m_configGroup;

private slots:
    void populateModel(const QStringList &whatChanged = QStringList());
};

Q_DECLARE_OPERATORS_FOR_FLAGS(PlasmaAppletItem::FilterFlags)

#endif /*PLASMAAPPLETSMODEL_H_*/
