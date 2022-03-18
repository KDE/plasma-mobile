// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "homescreenmodel.h"
#include "mobileshellsettings.h"

#include <QFileInfo>

using namespace MobileShell;

HomeScreenModel::HomeScreenModel(QObject *parent)
    : QAbstractListModel{parent}
    , m_selectedHomeScreen{MobileShellSettings::self()->homeScreenType()}
{
    // ensure config settings update
    connect(MobileShellSettings::self(), &MobileShellSettings::homeScreenTypeChanged, this, [this]() {
        Q_EMIT selectedHomeScreenChanged();
    });

    // load homescreen packages
    const auto packages = KPackage::PackageLoader::self()->listPackages(QStringLiteral("Plasma/Applet"), "plasma/plasmoids");

    for (const auto &metaData : packages) {
        const QStringList provides = metaData.value(QStringLiteral("X-Plasma-Provides"), QStringList());

        // check if the type of the containment is a homescreen
        if (!provides.contains("org.kde.phone.homescreen")) {
            continue;
        }

        KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("Plasma/Applet", QFileInfo(metaData.fileName()).path());

        // check if the package is valid
        if (!package.isValid()) {
            qWarning() << "Could not load homescreen" << metaData.fileName();
            continue;
        }

        m_packages.push_back(package);
    }
}

QVariant HomeScreenModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_packages.count()) {
        return QVariant();
    }

    if (role == NameRole) {
        return m_packages[index.row()].metadata().name();
    } else if (role == DescriptionRole) {
        return m_packages[index.row()].metadata().description();
    } else if (role == IdRole) {
        return m_packages[index.row()].metadata().pluginId();
    }
    return QVariant();
}

int HomeScreenModel::rowCount(const QModelIndex &parent) const
{
    return m_packages.size();
}

QHash<int, QByteArray> HomeScreenModel::roleNames() const
{
    return {{NameRole, "name"}, {DescriptionRole, "description"}, {IdRole, "id"}};
}

QString HomeScreenModel::selectedHomeScreen() const
{
    return m_selectedHomeScreen;
}

void HomeScreenModel::setSelectedHomeScreen(QString pluginId)
{
    MobileShellSettings::self()->setHomeScreenType(pluginId);
}
