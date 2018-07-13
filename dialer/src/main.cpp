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
#include "call-handler.h"

#include <TelepathyQt/Types>
#include <TelepathyQt/Debug>
#include <TelepathyQt/ClientRegistrar>
#include <TelepathyQt/CallChannel>
#include <TelepathyQt/ChannelClassSpec>
#include <TelepathyQt/ChannelFactory>
#include <TelepathyQt/Account>

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

#include <stdio.h>
#include <stdlib.h>

void myMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QFile file(QDir::homePath() + "/dialer.log");

    bool opened = file.open(QIODevice::WriteOnly | QIODevice::Append);
    Q_ASSERT(opened);

    QString strout;
    QTextStream out(&strout);
    out << QTime::currentTime().toString("hh:mm:ss.zzz ");
    out << context.function << ":" << context.line << " ";

    switch (type) {
        case QtDebugMsg:	  out << "DBG"; break;
        case QtInfoMsg:     out << "NFO"; break;
        case QtWarningMsg:  out << "WRN"; break;
        case QtCriticalMsg: out << "CRT"; break;
        case QtFatalMsg:    out << "FTL"; break;
    }

    out << " " << msg << '\n';

    // Write to log file
    QTextStream fileout(&file);
    fileout << strout;
    out.flush();

    // Write to stdout
    QTextStream console(stdout);
    console << strout;
    console.flush();
}

int main(int argc, char **argv)
{
    qInstallMessageHandler(myMessageOutput);
    QCommandLineParser parser;
    QApplication app(argc, argv);

    const QString description = i18n("Plasma Phone Dialer");
    const char version[] = PROJECT_VERSION;

//     app.setQuitOnLastWindowClosed(false);
    app.setApplicationVersion(version);
    app.setOrganizationDomain("kde.org");

    KDBusService service(KDBusService::Unique);

    parser.addVersionOption();
    parser.addHelpOption();
    parser.setApplicationDescription(description);

    QCommandLineOption daemonOption(QStringList() << QStringLiteral("d") <<
                                 QStringLiteral("daemon"),
                                 i18n("Daemon mode. run without displaying anything."));

    parser.addPositionalArgument("number", i18n("Call the given number"));

    parser.addOption(daemonOption);

    parser.process(app);

    Tp::registerTypes();

    Tp::AccountFactoryPtr accountFactory = Tp::AccountFactory::create(QDBusConnection::sessionBus(),
                                                                      Tp::Features() << Tp::Account::FeatureCore
    );

    Tp::ConnectionFactoryPtr connectionFactory = Tp::ConnectionFactory::create(QDBusConnection::sessionBus(),
                                                                               Tp::Features() << Tp::Connection::FeatureCore
                                                                                              << Tp::Connection::FeatureSelfContact
                                                                                              << Tp::Connection::FeatureConnected
    );

    Tp::ChannelFactoryPtr channelFactory = Tp::ChannelFactory::create(QDBusConnection::sessionBus());
    channelFactory->addCommonFeatures(Tp::Channel::FeatureCore);
    channelFactory->addFeaturesForCalls(Tp::Features() << Tp::CallChannel::FeatureContents
                                                       << Tp::CallChannel::FeatureCallState
                                                       << Tp::CallChannel::FeatureCallMembers
                                                       << Tp::CallChannel::FeatureLocalHoldState
    );

//     channelFactory->addFeaturesForTextChats(Tp::Features() << Tp::TextChannel::FeatureMessageQueue
//                                                            << Tp::TextChannel::FeatureMessageSentSignal
//                                                            << Tp::TextChannel::FeatureChatState
//                                                            << Tp::TextChannel::FeatureMessageCapabilities);

    Tp::ContactFactoryPtr contactFactory = Tp::ContactFactory::create(Tp::Features() << Tp::Contact::FeatureAlias
                                                                                     << Tp::Contact::FeatureAvatarData
    );

    Tp::ClientRegistrarPtr registrar = Tp::ClientRegistrar::create(accountFactory, connectionFactory,
                                                                   channelFactory, contactFactory);

    Tp::AccountPtr simAccount = Tp::Account::create(TP_QT_ACCOUNT_MANAGER_BUS_NAME, QStringLiteral("/org/freedesktop/Telepathy/Account/ofono/ofono/account0"),
                                                    connectionFactory, channelFactory);


    const QString packagePath("org.kde.phone.dialer");

    //usually we have an ApplicationWindow here, so we do not need to create a window by ourselves
    KDeclarative::QmlObject *obj = new KDeclarative::QmlObject();
    obj->setTranslationDomain(packagePath);
    obj->setInitializationDelayed(true);
    obj->loadPackage(packagePath);
    obj->engine()->rootContext()->setContextProperty("commandlineArguments", parser.positionalArguments());

    DialerUtils *dialerUtils = new DialerUtils(simAccount);
    obj->engine()->rootContext()->setContextProperty("dialerUtils", QVariant::fromValue(dialerUtils));

    obj->completeInitialization();

    if (!obj->package().metadata().isValid()) {
        return -1;
    }

    Tp::SharedPtr<CallHandler> callHandler(new CallHandler(dialerUtils));
    registrar->registerClient(Tp::AbstractClientPtr::dynamicCast(callHandler), "Plasma.Dialer");

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
            Q_UNUSED(workingDirectory);
            window->show();
            window->requestActivate();
            if (arguments.length() > 0) {
                QString numberArg = arguments[1];
                if (numberArg.startsWith("call://")) {
                    numberArg = numberArg.mid(7);
                }
                obj->rootObject()->metaObject()->invokeMethod(obj->rootObject(), "call", Q_ARG(QVariant, numberArg));
            }
        });
        if (!parser.isSet(daemonOption)) {
            window->show();
            window->requestActivate();
        }
        window->setTitle(obj->package().metadata().name());
        window->setIcon(QIcon::fromTheme(obj->package().metadata().iconName()));

        if (!parser.positionalArguments().isEmpty()) {
            QString numberArg = parser.positionalArguments().first();
            if (numberArg.startsWith("call://")) {
                numberArg = numberArg.mid(7);
            }
            qWarning() << "Calling" << numberArg;
            obj->rootObject()->metaObject()->invokeMethod(obj->rootObject(), "call", Q_ARG(QVariant, numberArg));
        }
    } else {
        qWarning() << "Error loading the ApplicationWindow";
    }

    return app.exec();
}
