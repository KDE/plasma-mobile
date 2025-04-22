// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QApplication>
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QString>

#include <KAboutData>

#include "quicksettingstest.h"
#include "version.h"

using namespace Qt::Literals::StringLiterals;

std::unique_ptr<QCommandLineParser> createParser()
{
    auto parser = std::make_unique<QCommandLineParser>();

    parser->addOption(QCommandLineOption(u"list"_s, u"List all of the quicksettings."_s));
    parser->addOption(QCommandLineOption(u"test-all"_s, u"Test all of the quicksettings."_s));
    parser->addVersionOption();
    parser->addHelpOption();
    parser->addPositionalArgument("test", "The test notification to send.");

    return parser;
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    auto parser = createParser();
    parser->process(app);

    QCoreApplication::setApplicationName(u"plasma-mobile-loadspeedtest"_s);
    QCoreApplication::setApplicationVersion(QStringLiteral(PLASMA_MOBILE_VERSION_STRING));
    QCoreApplication::setOrganizationDomain(u"kde.org"_s);

    QuickSettingsTest quickSettingsTest;
    quickSettingsTest.load();

    if (parser->isSet(u"list"_s)) {
        quickSettingsTest.list();
        return 0;
    } else if (parser->isSet(u"test-all"_s)) {
        quickSettingsTest.loadAll();
        return 0;
    } else if (parser->positionalArguments().size() == 0) {
        parser->showHelp();
        return 0;
    }

    // const auto args = parser->positionalArguments();
    // const QString name = args[0];

    // if (!found) {
    //     qInfo() << "Test not found.";
    //     return 0;
    // }

    return app.exec();
}
