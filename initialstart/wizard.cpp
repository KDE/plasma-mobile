// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "wizard.h"
#include "settings.h"
#include "utils.h"

#include <KPackage/PackageLoader>

#include <QFileInfo>
#include <QQmlComponent>

// TODO read distro provided config file
const QList<QString> WIZARD_MODULE_ORDER = {QStringLiteral("org.kde.plasma.mobileinitialstart.prepare"),
                                            QStringLiteral("org.kde.plasma.mobileinitialstart.time"),
                                            QStringLiteral("org.kde.plasma.mobileinitialstart.wifi"),
                                            QStringLiteral("org.kde.plasma.mobileinitialstart.cellular"),
                                            QStringLiteral("org.kde.plasma.mobileinitialstart.finished")};

Wizard::Wizard(QObject *parent, QQmlEngine *engine)
    : QObject{parent}
    , m_engine{engine}
{
}

void Wizard::load()
{
    if (!m_engine) {
        return;
    }

    qCDebug(LOGGING_CATEGORY) << "Loading initialstart packages...";

    // load initialstart packages
    const auto packages = KPackage::PackageLoader::self()->listPackages(QStringLiteral("KPackage/GenericQML"), QStringLiteral("plasma/mobileinitialstart"));
    for (auto &metaData : packages) {
        KPackage::Package package = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("KPackage/GenericQML"), QFileInfo(metaData.fileName()).path());
        if (!package.isValid()) {
            qCWarning(LOGGING_CATEGORY) << "initialstart package invalid:" << metaData.fileName();
            continue;
        }
        m_modulePackages.push_back({new KPluginMetaData{metaData}, package});
    }

    // sort modules by order
    std::sort(m_modulePackages.begin(), m_modulePackages.end(), [](const auto &lhs, const auto &rhs) {
        return WIZARD_MODULE_ORDER.indexOf(lhs.first->pluginId()) < WIZARD_MODULE_ORDER.indexOf(rhs.first->pluginId());
    });

    QQmlComponent *c = new QQmlComponent(m_engine, this);

    // load initialstart QML items
    for (auto &pair : m_modulePackages) {
        // load QML from kpackage
        c->loadUrl(pair.second.fileUrl("mainscript"), QQmlComponent::PreferSynchronous);

        auto created = c->create(m_engine->rootContext());
        auto createdItem = qobject_cast<QQuickItem *>(created);

        // print errors if there were issues loading
        if (!createdItem) {
            qCWarning(LOGGING_CATEGORY) << "Unable to load initialstart module:" << created;
            for (auto error : c->errors()) {
                qCWarning(LOGGING_CATEGORY) << error;
            }
            delete created;
            continue;
        }

        m_moduleItems.push_back(createdItem);

        qCDebug(LOGGING_CATEGORY) << "Loaded initialstart module" << pair.first->pluginId();
    }

    delete c;
}

void Wizard::setTestingMode(bool testingMode)
{
    if (testingMode != m_testingMode) {
        m_testingMode = testingMode;
        Q_EMIT testingModeChanged();
    }
}

bool Wizard::testingMode()
{
    return m_testingMode;
}

QList<QQuickItem *> Wizard::steps()
{
    return m_moduleItems;
}

void Wizard::wizardFinished()
{
    Settings::self()->setWizardFinished();
    QCoreApplication::quit();
}
