// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreen.h"
#include "application.h"
#include "applicationfolder.h"
#include "pinnedmodel.h"
#include "windowlistener.h"

#include <KIO/ApplicationLauncherJob>
#include <KWindowSystem>

#include <QDebug>
#include <QQuickItem>
#include <QtQml>

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
{
    setHasConfigurationInterface(true);

    WindowListener::instance(); // ensure it is created

    ApplicationListModel *applicationListModel = new ApplicationListModel{this};
    qmlRegisterSingletonType<ApplicationListModel>("org.kde.phone.homescreen.halcyon",
                                                   1,
                                                   0,
                                                   "ApplicationListModel",
                                                   [applicationListModel](QQmlEngine *, QJSEngine *) -> QObject * {
                                                       return applicationListModel;
                                                   });

    PinnedModel *pinnedModel = new PinnedModel{this, this};
    qmlRegisterSingletonType<PinnedModel>("org.kde.phone.homescreen.halcyon", 1, 0, "PinnedModel", [pinnedModel](QQmlEngine *, QJSEngine *) -> QObject * {
        return pinnedModel;
    });

    qmlRegisterType<Application>("org.kde.phone.homescreen.halcyon", 1, 0, "Application");
    qmlRegisterType<ApplicationFolder>("org.kde.phone.homescreen.halcyon", 1, 0, "ApplicationFolder");
}

HomeScreen::~HomeScreen() = default;

bool HomeScreen::showingDesktop() const
{
    return KWindowSystem::showingDesktop();
}

void HomeScreen::setShowingDesktop(bool showingDesktop)
{
    KWindowSystem::setShowingDesktop(showingDesktop);
}

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "package/metadata.json")

#include "homescreen.moc"
