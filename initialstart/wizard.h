// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QQuickItem>

#include <KPackage/Package>
#include <KPluginMetaData>

class Wizard : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QQuickItem *> steps READ steps CONSTANT)
    Q_PROPERTY(bool testingMode READ testingMode NOTIFY testingModeChanged)

public:
    Wizard(QObject *parent = nullptr, QQmlEngine *engine = nullptr);

    void load();

    void setTestingMode(bool testingMode);
    bool testingMode();

    QList<QQuickItem *> steps();

public Q_SLOTS:
    void wizardFinished();

Q_SIGNALS:
    void testingModeChanged();

private:
    QList<std::pair<KPluginMetaData *, KPackage::Package>> m_modulePackages;
    QList<QQuickItem *> m_moduleItems;

    bool m_testingMode;
    QQmlEngine *m_engine;
};
