// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "halcyonplugin.h"
#include "application.h"
#include "applicationfolder.h"
#include "applicationlistmodel.h"
#include "pinnedmodel.h"
#include "windowlistener.h"

void HalcyonPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.private.mobile.homescreen.halcyon"));

    WindowListener::instance(); // ensure it is created

    ApplicationListModel *applicationListModel = new ApplicationListModel{this};
    qmlRegisterSingletonType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel", [applicationListModel](QQmlEngine *, QJSEngine *) -> QObject * {
        return applicationListModel;
    });

    PinnedModel *pinnedModel = new PinnedModel{this};
    qmlRegisterSingletonType<PinnedModel>(uri, 1, 0, "PinnedModel", [pinnedModel](QQmlEngine *, QJSEngine *) -> QObject * {
        return pinnedModel;
    });

    qmlRegisterType<Application>(uri, 1, 0, "Application");
    qmlRegisterType<ApplicationFolder>(uri, 1, 0, "ApplicationFolder");
}
