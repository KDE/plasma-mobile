/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <QApplication>

#include "dialerutils.h"

#include <klocalizedstring.h>
#include <qcommandlineparser.h>
#include <qcommandlineoption.h>
#include <QQuickItem>
#include <QtQml>

#include <kpackage/package.h>
#include <kpackage/packageloader.h>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlExpression>
#include <QQmlProperty>
#include <QQuickWindow>
#include <kdeclarative/qmlobject.h>
#include <KAboutData>
#include <KDBusService>

int main(int argc, char **argv)
{
    QCommandLineParser parser;
    QApplication app(argc, argv);

    app.setQuitOnLastWindowClosed(false);
    KDBusService service(KDBusService::Unique);

    const QString description = i18n("Plasma Phone Dialer");
    const char version[] = PROJECT_VERSION;

    app.setApplicationVersion(version);
    parser.addVersionOption();
    parser.addHelpOption();
    parser.setApplicationDescription(description);

    QCommandLineOption daemonOption(QStringList() << QStringLiteral("d") <<
                                 QStringLiteral("daemon"),
                                 i18n("Daemon mode. run without displaying anything."));
    QCommandLineOption dialOption(QStringList() << QStringLiteral("c") << QStringLiteral("call"),
                                         i18n("Call the given number"),
                                         QStringLiteral("number"));

    parser.addOption(dialOption);
    parser.addOption(daemonOption);

    parser.process(app);

    const QString packagePath("org.kde.phone.dialer");

    //usually we have an ApplicationWindow here, so we do not need to create a window by ourselves
    KDeclarative::QmlObject *obj = new KDeclarative::QmlObject();
    obj->setTranslationDomain(packagePath);
    obj->setInitializationDelayed(true);
    obj->loadPackage(packagePath);
    obj->engine()->rootContext()->setContextProperty("commandlineArguments", parser.positionalArguments());

    DialerUtils *dialerUtils = new DialerUtils;
    obj->engine()->rootContext()->setContextProperty("dialerUtils", QVariant::fromValue(dialerUtils));

    obj->completeInitialization();

    if (!obj->package().metadata().isValid()) {
        return -1;
    }

    KPluginMetaData data = obj->package().metadata();
    // About data
    KAboutData aboutData(data.pluginId(), data.name(), data.version(), data.description(), KAboutLicense::byKeyword(data.license()).key());

    for (auto author : data.authors()) {
        aboutData.addAuthor(author.name(), author.task(), author.emailAddress(), author.webAddress(), author.ocsUsername());
    }

    //The root is not a window?
    //have to use a normal QQuickWindow since the root item is already created
    QWindow *window = qobject_cast<QWindow *>(obj->rootObject());
    if (window) {
        QObject::connect(&service, &KDBusService::activateRequested, [=](const QStringList &arguments, const QString &workingDirectory) {
            Q_UNUSED(arguments)
            Q_UNUSED(workingDirectory);
            window->show();
            window->requestActivate();
        });
        if (!parser.isSet(daemonOption)) {
            window->show();
            window->requestActivate();
        }
        window->setTitle(obj->package().metadata().name());
        window->setIcon(QIcon::fromTheme(obj->package().metadata().iconName()));

        if (parser.isSet(dialOption)) {
            qWarning() << "Calling" << parser.value(dialOption);
            obj->rootObject()->metaObject()->invokeMethod(obj->rootObject(), "call", Q_ARG(QVariant, parser.value(dialOption)));
        }
    } else {
        qWarning() << "Error loading the ApplicationWindow";
    }

    return app.exec();
}

