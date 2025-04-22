#include "quicksettingstest.h"

#include <KLocalizedContext>
#include <QElapsedTimer>
#include <QFileInfo>
#include <QQmlContext>
#include <QQmlEngine>

QuickSettingsTest::QuickSettingsTest(QObject *parent)
    : QObject{parent}
    , m_engine{new QQmlEngine{this}}
{
    // Create translation context
    KLocalizedContext *i18nContext = new KLocalizedContext(m_engine);
    i18nContext->setTranslationDomain(QLatin1String("loadspeedtest"));
    m_engine->rootContext()->setContextObject(i18nContext);
}

void QuickSettingsTest::load()
{
    // load quicksettings packages
    auto packages = KPackage::PackageLoader::self()->listPackages(QStringLiteral("KPackage/GenericQML"), "plasma/quicksettings");

    for (const auto &metaData : packages) {
        KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("KPackage/GenericQML", QFileInfo(metaData.fileName()).path());
        if (!package.isValid()) {
            qWarning() << "Quick setting package invalid:" << metaData.fileName();
            continue;
        }
        m_packages.push_back(metaData);
    }
}

void QuickSettingsTest::loadAll()
{
    for (const auto &metaData : m_packages) {
        loadQuickSetting(metaData);
    }

    for (const QString &message : m_messages) {
        qInfo() << message;
    }
}

void QuickSettingsTest::loadQuickSetting(KPluginMetaData metaData)
{
    // Load KPackage
    const KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("KPackage/GenericQML", QFileInfo(metaData.fileName()).path());
    if (!package.isValid()) {
        return;
    }

    QQmlComponent *component = new QQmlComponent(m_engine, this);

    connect(component, &QQmlComponent::statusChanged, this, [this, metaData, component]() {
        afterQuickSettingLoad(m_engine, metaData, component);
    });

    // Load QML from KPackage async
    component->loadUrl(package.fileUrl("mainscript"), QQmlComponent::PreferSynchronous);
}

void QuickSettingsTest::list() const
{
    qInfo() << "Quick settings packages:";
    for (const KPluginMetaData &metaData : m_packages) {
        qInfo() << metaData.pluginId();
    }
}

void QuickSettingsTest::afterQuickSettingLoad(QQmlEngine *engine, KPluginMetaData metaData, QQmlComponent *component)
{
    // Start time
    QElapsedTimer timer;
    timer.start();

    QObject *object = component->create();
    if (!object) {
        qWarning() << "Unable to load quick setting element:" << metaData.pluginId();
        component->deleteLater();
        return;
    }

    if (component->isError()) {
        qWarning() << "Unable to load quick setting element:" << metaData.pluginId();
        for (auto error : component->errors()) {
            qWarning() << error;
        }
        component->deleteLater();
    }

    // Finished time
    qInfo() << "======================================================";
    qInfo() << metaData.pluginId() << "loaded in" << timer.elapsed();
    m_messages.push_back(metaData.pluginId() + " loaded in " + QString::number(timer.elapsed()));
    qInfo() << "======================================================";

    component->deleteLater();
    object->deleteLater();
}