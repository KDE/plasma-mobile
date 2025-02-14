// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QCommandLineParser>
#include <QCoreApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QString>

#include <KAboutData>

#include "tests.h"
#include "version.h"

using namespace Qt::Literals::StringLiterals;

std::unique_ptr<QCommandLineParser> createParser()
{
    auto parser = std::make_unique<QCommandLineParser>();
    parser->addOption(QCommandLineOption(u"list"_s, u"Lists the possible test notifications that can be set."_s));
    parser->addVersionOption();
    parser->addHelpOption();
    parser->addPositionalArgument("test", "The test notification to send.");
    return parser;
}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    auto parser = createParser();
    parser->process(app);

    QCoreApplication::setApplicationName(u"plasma-mobile-notificationtest"_s);
    QCoreApplication::setApplicationVersion(QStringLiteral(PLASMA_MOBILE_VERSION_STRING));
    QCoreApplication::setOrganizationDomain(u"kde.org"_s);

    std::vector<std::unique_ptr<NotificationTest>> notificationTests;
    notificationTests.push_back(std::make_unique<BasicNotificationTest>());
    notificationTests.push_back(std::make_unique<UrlNotificationTest>());
    notificationTests.push_back(std::make_unique<ReplyNotificationTest>());
    notificationTests.push_back(std::make_unique<LowUrgencyNotificationTest>());
    notificationTests.push_back(std::make_unique<HighUrgencyNotificationTest>());
    notificationTests.push_back(std::make_unique<CriticalUrgencyNotificationTest>());
    notificationTests.push_back(std::make_unique<JobNotificationTest>());

    if (parser->isSet(u"list"_s)) {
        for (auto &notification : notificationTests) {
            qInfo() << notification->name();
        }
        return 0;
    } else if (parser->positionalArguments().size() == 0) {
        parser->showHelp();
        return 0;
    }

    const auto args = parser->positionalArguments();
    const QString name = args[0];

    bool found = false;
    for (auto &notification : notificationTests) {
        if (notification->name() == name) {
            qInfo() << "Sending notification" << notification->name();
            notification->sendNotification(app);
            found = true;
            break;
        }
    }

    if (!found) {
        qInfo() << "Test not found.";
        return 0;
    }

    return app.exec();
}
