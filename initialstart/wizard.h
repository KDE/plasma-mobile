// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QQuickItem>

#include <KPackage/Package>
#include <KPluginMetaData>

#include "initialstartmodule.h"

class Wizard : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<InitialStartModule *> steps READ steps NOTIFY stepsChanged)
    Q_PROPERTY(int stepsCount READ stepsCount NOTIFY stepsChanged)
    Q_PROPERTY(bool testingMode READ testingMode NOTIFY testingModeChanged)

public:
    Wizard(QObject *parent = nullptr, QQmlEngine *engine = nullptr);

    void load();

    void setTestingMode(bool testingMode);
    bool testingMode();

    QList<InitialStartModule *> steps();
    int stepsCount();

public Q_SLOTS:
    void wizardFinished();

Q_SIGNALS:
    void stepsChanged();
    void testingModeChanged();

private Q_SLOTS:
    void determineAvailableModuleItems();

private:
    QList<std::pair<KPluginMetaData *, KPackage::Package>> m_modulePackages;
    QList<InitialStartModule *> m_availableModuleItems;
    QList<InitialStartModule *> m_moduleItems;

    bool m_testingMode;
    QQmlEngine *m_engine;
};
