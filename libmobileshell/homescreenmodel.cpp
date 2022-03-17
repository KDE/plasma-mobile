// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "homescreenmodel.h"

using namespace MobileShell;

HomeScreenModel::HomeScreenModel(QObject *parent)
{
    //     QQmlEngine *engine = qmlEngine(this);
    //
    //     const auto packages = KPackage::PackageLoader::self()->listPackages(QStringLiteral("KPackage/GenericQML"), "plasma/homescreens");
    //
    //     for (const auto &metaData: packages) {
    //         KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("KPackage/GenericQML", QFileInfo(metaData.fileName()).path());
    //
    //         if (!package.isValid()) {
    //             qWarning() << "Could not load homescreen" << metaData.fileName();
    //             continue;
    //         }
    //
    //
    //
    //     }
    //
}
