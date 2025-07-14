/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <waydroidapplication.h>

#include <QRegularExpression>
#include <QStringLiteral>

using namespace Qt::StringLiterals;

static const QRegularExpression nameRegExp(u"^Name:\\s*(\\S+)"_s);
static const QRegularExpression packageNameRegExp(u"^packageName:\\s*(\\S+)"_s);

WaydroidApplication::WaydroidApplication(QObject *parent)
    : QObject{parent}
{
    // Nothing
}

WaydroidApplication::Ptr WaydroidApplication::fromWaydroidLog(QTextStream &inFile)
{
    WaydroidApplication::Ptr app;

    const QString line = inFile.readLine();
    const QRegularExpressionMatch nameMatch = nameRegExp.match(line);

    if (!nameMatch.hasMatch() || nameMatch.lastCapturedIndex() == 0) {
        return nullptr;
    }

    app = std::make_shared<WaydroidApplication>();
    app->m_name = nameMatch.captured(nameMatch.lastCapturedIndex());

    qint64 oldPos = inFile.pos();
    while (!inFile.atEnd()) {
        const QString line = inFile.readLine();
        if (line.trimmed().isEmpty()) {
            continue;
        }

        const QRegularExpressionMatch nameMatch = nameRegExp.match(line);
        if (nameMatch.hasMatch()) {
            inFile.seek(oldPos); // Revert file cursor position for the next Application parsing
            return app;
        }

        const QRegularExpressionMatch packageNameMatch = packageNameRegExp.match(line);
        if (packageNameMatch.hasMatch() && packageNameMatch.lastCapturedIndex() > 0) {
            app->m_packageName = packageNameMatch.captured(packageNameMatch.lastCapturedIndex());
        }

        oldPos = inFile.pos();
    }

    return app;
}

QString WaydroidApplication::name() const
{
    return m_name;
}

QString WaydroidApplication::packageName() const
{
    return m_packageName;
}
