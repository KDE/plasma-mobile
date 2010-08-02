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

#include "plasmaappletitemmodel_p.h"

#include <KStandardDirs>
#include <KSycoca>

PlasmaAppletItem::PlasmaAppletItem(PlasmaAppletItemModel *model,
                                   const KPluginInfo& info,
                                   FilterFlags flags)
    : QObject(model), m_model(model)
{
    QMap<QString, QVariant> attrs;
    attrs.insert("name", info.name());
    attrs.insert("pluginName", info.pluginName());
    attrs.insert("description", info.comment());
    attrs.insert("category", info.category().toLower());
    attrs.insert("license", info.fullLicense().name(KAboutData::FullName));
    attrs.insert("website", info.website());
    attrs.insert("version", info.version());
    attrs.insert("author", info.author());
    attrs.insert("email", info.email());
    attrs.insert("favorite", flags & Favorite ? true : false);

    const QString api(info.property("X-Plasma-API").toString());
    bool local = false;
    if (!api.isEmpty()) {
        QDir dir(KStandardDirs::locateLocal("data", "plasma/plasmoids/" + info.pluginName() + '/'));
        local = dir.exists();
    }
    attrs.insert("local", local);

    //attrs.insert("recommended", flags & Recommended ? true : false);
    setText(info.name() + " - "+ info.category().toLower());

    const QString iconName = info.icon().isEmpty() ? "application-x-plasma" : info.icon();
    KIcon icon(iconName);
    attrs.insert("icon", static_cast<QIcon>(icon));
    setIcon(icon);
    setData(attrs);

    //QML can't disassemble attrs :/
    setData(info.pluginName(), PlasmaAppletItemModel::PluginNameRole);
    setData(info.comment(), PlasmaAppletItemModel::DescriptionRole);
    setData(info.category().toLower(), PlasmaAppletItemModel::CategoryRole);
    setData(info.fullLicense().name(KAboutData::FullName), PlasmaAppletItemModel::LicenseRole);
    setData(info.website(), PlasmaAppletItemModel::WebsiteRole);
    setData(info.version(), PlasmaAppletItemModel::VersionRole);
    setData(info.author(), PlasmaAppletItemModel::AuthorRole);
    setData(info.email(), PlasmaAppletItemModel::EmailRole);
}

QString PlasmaAppletItem::pluginName() const
{
    return data().toMap()["pluginName"].toString();
}

QString PlasmaAppletItem::name() const
{
    return data().toMap()["name"].toString();
}

QString PlasmaAppletItem::description() const
{
    return data().toMap()["description"].toString();
}

QString PlasmaAppletItem::license() const
{
    return data().toMap()["license"].toString();
}

QString PlasmaAppletItem::category() const
{
    return data().toMap()["category"].toString();
}

QString PlasmaAppletItem::website() const
{
    return data().toMap()["website"].toString();
}

QString PlasmaAppletItem::version() const
{
    return data().toMap()["version"].toString();
}

QString PlasmaAppletItem::author() const
{
    return data().toMap()["author"].toString();
}

QString PlasmaAppletItem::email() const
{
    return data().toMap()["email"].toString();
}

int PlasmaAppletItem::running() const
{
    return data().toMap()["runningCount"].toInt();
}

void PlasmaAppletItem::setFavorite(bool favorite)
{
    QMap<QString, QVariant> attrs = data().toMap();
    attrs.insert("favorite", favorite ? true : false);
    setData(QVariant(attrs));

    QString pluginName = attrs["pluginName"].toString();
    m_model->setFavorite(pluginName, favorite);
}

bool PlasmaAppletItem::isLocal() const
{
    return data().toMap()["local"].toBool();
}

void PlasmaAppletItem::setRunning(int count)
{
    QMap<QString, QVariant> attrs = data().toMap();
    attrs.insert("running", count > 0); //bool for the filter
    attrs.insert("runningCount", count);
    setData(QVariant(attrs));
}

bool PlasmaAppletItem::passesFiltering(const KCategorizedItemsViewModels::Filter & filter) const
{
    return data().toMap()[filter.first] == filter.second;
}

QVariantList PlasmaAppletItem::arguments() const
{
    return qvariant_cast<QVariantList>(data().toMap()["arguments"]);
}

QMimeData *PlasmaAppletItem::mimeData() const
{
    QMimeData *data = new QMimeData();
    QByteArray appletName;
    appletName += pluginName().toUtf8();
    data->setData(mimeTypes().at(0), appletName);
    return data;
}

QStringList PlasmaAppletItem::mimeTypes() const
{
    QStringList types;
    types << QLatin1String("text/x-plasmoidservicename");
    return types;
}

PlasmaAppletItemModel* PlasmaAppletItem::appletItemModel()
{
    return m_model;
}

//PlasmaAppletItemModel

PlasmaAppletItemModel::PlasmaAppletItemModel(QObject * parent)
    : QStandardItemModel(parent)
{
    KConfig config("plasmarc");
    m_configGroup = KConfigGroup(&config, "Applet Browser");
    m_favorites = m_configGroup.readEntry("favorites").split(',');
    connect(KSycoca::self(), SIGNAL(databaseChanged(QStringList)), this, SLOT(populateModel(QStringList)));

    //This is to make QML that is understand it
    QHash<int, QByteArray> newRoleNames = roleNames();
    newRoleNames[PluginNameRole] = "pluginName";
    newRoleNames[DescriptionRole] = "description";
    newRoleNames[CategoryRole] = "category";
    newRoleNames[LicenseRole] = "license";
    newRoleNames[WebsiteRole] = "website";
    newRoleNames[VersionRole] = "version";
    newRoleNames[AuthorRole] = "author";
    newRoleNames[EmailRole] = "email";

    setRoleNames(newRoleNames);

    setSortRole(Qt::DisplayRole);
}

void PlasmaAppletItemModel::populateModel(const QStringList &whatChanged)
{
    if (!whatChanged.isEmpty() && !whatChanged.contains("services")) {
        return;
    }

    clear();
    //kDebug() << "populating model, our application is" << m_application;

    //kDebug() << "number of applets is"
    //         <<  Plasma::Applet::listAppletInfo(QString(), m_application).count();
    foreach (const KPluginInfo &info, Plasma::Applet::listAppletInfo(QString(), m_application)) {
        //kDebug() << info.pluginName() << "NoDisplay" << info.property("NoDisplay").toBool();
        if (info.property("NoDisplay").toBool() || info.category() == i18n("Containments")) {
            // we don't want to show the hidden category
            continue;
        }
        //kDebug() << info.pluginName() << " is the name of the plugin\n";

        //qDebug() << info.name() << info.property("X-Plasma-Thumbnail");
        //qDebug() << info.entryPath();

        PlasmaAppletItem::FilterFlags flags(PlasmaAppletItem::NoFilter);
        if (m_favorites.contains(info.pluginName())) {
            flags |= PlasmaAppletItem::Favorite;
        }

        appendRow(new PlasmaAppletItem(this, info, flags));
    }
}

void PlasmaAppletItemModel::setRunningApplets(const QHash<QString, int> &apps)
{
    //foreach item, find that string and set the count
    for (int r = 0; r < rowCount(); ++r) {
        QStandardItem *i = item(r);
        PlasmaAppletItem *p = dynamic_cast<PlasmaAppletItem *>(i);

        if (p) {
            const bool running = apps.value(p->pluginName());
            p->setRunning(running);
        }
    }
}

void PlasmaAppletItemModel::setRunningApplets(const QString &name, int count)
{
    for (int r=0; r<rowCount(); ++r) {
        QStandardItem *i = item(r);
        PlasmaAppletItem *p = dynamic_cast<PlasmaAppletItem *>(i);
        if (p && p->pluginName() == name) {
            p->setRunning(count);
        }
    }
}

QStringList PlasmaAppletItemModel::mimeTypes() const
{
    QStringList types;
    types << QLatin1String("text/x-plasmoidservicename");
    return types;
}

QSet<QString> PlasmaAppletItemModel::categories() const
{
    QSet<QString> cats;
    for (int r = 0; r < rowCount(); ++r) {
        QStandardItem *i = item(r);
        PlasmaAppletItem *p = dynamic_cast<PlasmaAppletItem *>(i);
        if (p) {
            cats.insert(p->category());
        }
    }

    return cats;
}

QMimeData *PlasmaAppletItemModel::mimeData(const QModelIndexList &indexes) const
{
    //kDebug() << "GETTING MIME DATA\n";
    if (indexes.count() <= 0) {
        return 0;
    }

    QStringList types = mimeTypes();

    if (types.isEmpty()) {
        return 0;
    }

    QMimeData *data = new QMimeData();

    QString format = types.at(0);

    QByteArray appletNames;
    int lastRow = -1;
    foreach (const QModelIndex &index, indexes) {
        if (index.row() == lastRow) {
            continue;
        }

        lastRow = index.row();
        PlasmaAppletItem *selectedItem = (PlasmaAppletItem *) itemFromIndex(index);
        appletNames += '\n' + selectedItem->pluginName().toUtf8();
        //kDebug() << selectedItem->pluginName() << index.column() << index.row();
    }

    data->setData(format, appletNames);
    return data;
}

void PlasmaAppletItemModel::setFavorite(const QString &plugin, bool favorite)
{
    if (favorite) {
        if (!m_favorites.contains(plugin)) {
            m_favorites.append(plugin);
        }
    } else if (m_favorites.contains(plugin)) {
        m_favorites.removeAll(plugin);
    }

    m_configGroup.writeEntry("favorites", m_favorites.join(","));
    m_configGroup.sync();
}

void PlasmaAppletItemModel::setApplication(const QString &app)
{
    m_application = app;
    populateModel();
}

QString &PlasmaAppletItemModel::Application()
{
    return m_application;
}

//#include <plasmaappletitemmodel_p.moc>

