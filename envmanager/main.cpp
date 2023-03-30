// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QApplication>
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QString>

#include <KAboutData>
#include <KLocalizedString>

#include "settings.h"
#include "version.h"

QCommandLineParser *createParser()
{
    QCommandLineParser *parser = new QCommandLineParser;
    parser->addOption(QCommandLineOption(QStringLiteral("apply-settings"), i18n("Applies the correct system settings for the current environment.")));
    parser->addVersionOption();
    parser->addHelpOption();
    return parser;
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // parse command
    QScopedPointer<QCommandLineParser> parser{createParser()};
    parser->process(app);

    // start wizard
    KLocalizedString::setApplicationDomain("plasma-mobile-envmanager");
    QCoreApplication::setApplicationName(QStringLiteral("plasma-mobile-envmanager"));
    QCoreApplication::setApplicationVersion(QStringLiteral(PLASMA_MOBILE_VERSION_STRING));
    QCoreApplication::setOrganizationDomain(QStringLiteral("kde.org"));

    // apply configuration
    if (parser->isSet(QStringLiteral("apply-settings"))) {
        Settings::self()->applyConfiguration();
    } else {
        parser->showHelp();
    }

    return 0;
}
