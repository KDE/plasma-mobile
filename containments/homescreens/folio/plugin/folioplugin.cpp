// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "folioplugin.h"
#include "applicationlistmodel.h"
#include "desktopmodel.h"

void HalcyonPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.private.mobile.homescreen.folio"));

    qmlRegisterSingletonType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return ApplicationListModel::self();
    });

    qmlRegisterType<DesktopModel>(uri, 1, 0, "DesktopModel");
}
