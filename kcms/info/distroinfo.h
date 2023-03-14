/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include <KOSRelease>
#include <QObject>

// clang-format off

#define PROPERTY(type, name)                                                                                                                                                                                                                   \
    type name() const { return m_osrelease.name(); }\

// clang-format off

#ifndef DISTROINFO_H
#define DISTROINFO_H

class DistroInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QStringList idLike READ idLike CONSTANT)
    Q_PROPERTY(QString versionCodename READ versionCodename CONSTANT)
    Q_PROPERTY(QString versionId READ versionId CONSTANT)
    Q_PROPERTY(QString prettyName READ prettyName CONSTANT)
    Q_PROPERTY(QString ansiColor READ ansiColor CONSTANT)
    Q_PROPERTY(QString cpeName READ cpeName CONSTANT)
    Q_PROPERTY(QString homeUrl READ homeUrl CONSTANT)
    Q_PROPERTY(QString documentationUrl READ documentationUrl CONSTANT)
    Q_PROPERTY(QString supportUrl READ supportUrl CONSTANT)
    Q_PROPERTY(QString bugReportUrl READ bugReportUrl CONSTANT)
    Q_PROPERTY(QString privacyPolicyUrl READ privacyPolicyUrl CONSTANT)
    Q_PROPERTY(QString buildId READ buildId CONSTANT)
    Q_PROPERTY(QString variant READ variant CONSTANT)
    Q_PROPERTY(QString variantId READ variantId CONSTANT)
    Q_PROPERTY(QString logo READ logo CONSTANT)

public:
    DistroInfo(QObject *parent = nullptr);

    PROPERTY(QString, name)
    PROPERTY(QString, version)
    PROPERTY(QString, id)
    PROPERTY(QStringList, idLike)
    PROPERTY(QString, versionCodename)
    PROPERTY(QString, versionId)
    PROPERTY(QString, prettyName)
    PROPERTY(QString, ansiColor)
    PROPERTY(QString, cpeName)
    PROPERTY(QString, homeUrl)
    PROPERTY(QString, documentationUrl)
    PROPERTY(QString, supportUrl)
    PROPERTY(QString, bugReportUrl)
    PROPERTY(QString, privacyPolicyUrl)
    PROPERTY(QString, buildId)
    PROPERTY(QString, variant)
    PROPERTY(QString, variantId)
    PROPERTY(QString, logo)

private:
    KOSRelease m_osrelease;
};

#endif // DISTROINFO_H
