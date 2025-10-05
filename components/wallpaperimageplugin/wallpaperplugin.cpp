// SPDX-FileCopyrightText: 2023 Méven Car <meven@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "wallpaperplugin.h"

#include <QApplication>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusMessage>
#include <QDBusReply>

#include <KLocalizedString>
#include <KPackage/Package>
#include <KPackage/PackageLoader>
#include <KPluginFactory>

#include <QCoroDBusPendingCall>
#include <QFile>
#include <QFileInfo>

WallpaperPlugin::WallpaperPlugin(QObject *parent)
    : QObject{parent}
    , m_homescreenConfig{new QQmlPropertyMap{this}}
    , m_lockscreenConfig{new QQmlPropertyMap{this}}
    , m_homescreenConfigFile{KSharedConfig::openConfig("plasma-org.kde.plasma.mobileshell-appletsrc")}
    , m_lockscreenConfigFile{KSharedConfig::openConfig("kscreenlockerrc")}
{
    m_lockscreenConfigWatcher = KConfigWatcher::create(m_lockscreenConfigFile);

    const bool connected = QDBusConnection::sessionBus().connect(QStringLiteral("org.kde.plasmashell"),
                                                                 QStringLiteral("/PlasmaShell"),
                                                                 QStringLiteral("org.kde.PlasmaShell"),
                                                                 QStringLiteral("wallpaperChanged"),
                                                                 this,
                                                                 SLOT(loadHomescreenSettings()));
    if (!connected) {
        qWarning() << "Could not connect to dbus service org.kde.plasmashell to listen to wallpaperChanged";
    }

    connect(m_lockscreenConfigWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group) {
	Q_UNUSED(group)
        loadLockscreenSettings();
    });

    loadLockscreenSettings();
    loadHomescreenSettings();
}

PlasmaQuick::ConfigModel *WallpaperPlugin::wallpaperPluginModel()
{
    if (!m_wallpaperPluginModel) {
        m_wallpaperPluginModel = new WallpaperConfigModel(this);
        QDBusConnection::sessionBus().connect(QString(),
                                              QStringLiteral("/KPackage/Plasma/Wallpaper"),
                                              QStringLiteral("org.kde.plasma.kpackage"),
                                              QStringLiteral("packageInstalled"),
                                              m_wallpaperPluginModel,
                                              SLOT(repopulate()));
        QDBusConnection::sessionBus().connect(QString(),
                                              QStringLiteral("/KPackage/Plasma/Wallpaper"),
                                              QStringLiteral("org.kde.plasma.kpackage"),
                                              QStringLiteral("packageUpdated"),
                                              m_wallpaperPluginModel,
                                              SLOT(repopulate()));
        QDBusConnection::sessionBus().connect(QString(),
                                              QStringLiteral("/KPackage/Plasma/Wallpaper"),
                                              QStringLiteral("org.kde.plasma.kpackage"),
                                              QStringLiteral("packageUninstalled"),
                                              m_wallpaperPluginModel,
                                              SLOT(repopulate()));
    }
    return m_wallpaperPluginModel;
}

QQmlPropertyMap *WallpaperPlugin::homescreenConfiguration() const
{
    return m_homescreenConfig;
}

QQmlPropertyMap *WallpaperPlugin::lockscreenConfiguration() const
{
    return m_lockscreenConfig;
}

QString WallpaperPlugin::homescreenWallpaperPlugin() const
{
    return m_homescreenWallpaperPlugin;
}

QString WallpaperPlugin::homescreenWallpaperPluginSource()
{
    if (m_homescreenWallpaperPlugin.isEmpty()) {
        return QString();
    }

    const auto model = wallpaperPluginModel();
    const auto wallpaperPluginCount = model->count();
    for (int i = 0; i < wallpaperPluginCount; ++i) {
        if (model->data(model->index(i), PlasmaQuick::ConfigModel::PluginNameRole) == m_homescreenWallpaperPlugin) {
            return model->data(model->index(i), PlasmaQuick::ConfigModel::SourceRole).toString();
        }
    }

    return QString();
}

void WallpaperPlugin::setHomescreenWallpaperPlugin(const QString &wallpaperPlugin)
{
    auto containmentsGroup = m_homescreenConfigFile->group(QStringLiteral("Containments"));

    for (const auto &contIndex : containmentsGroup.groupList()) {
        const auto contConfig = containmentsGroup.group(contIndex);
        if (contConfig.readEntry("activityId").isEmpty()) {
            continue;
        }

        QString containmentIdx = contIndex;
        auto containmentConfigGroup = containmentsGroup.group(containmentIdx);

        // pick first screen that is found to load the wallpaper plugin
        m_homescreenConfig = loadConfiguration(containmentConfigGroup, wallpaperPlugin, true);
        m_homescreenWallpaperPlugin = wallpaperPlugin;
        break;
    }

    // saveHomescreenSettings();
    Q_EMIT homescreenWallpaperPluginChanged();
}

QString WallpaperPlugin::lockscreenWallpaperPlugin() const
{
    return m_lockscreenWallpaperPlugin;
}

QString WallpaperPlugin::lockscreenWallpaperPluginSource()
{
    if (m_lockscreenWallpaperPlugin.isEmpty()) {
        return QString();
    }

    const auto model = wallpaperPluginModel();
    const auto wallpaperPluginCount = model->count();
    for (int i = 0; i < wallpaperPluginCount; ++i) {
        if (model->data(model->index(i), PlasmaQuick::ConfigModel::PluginNameRole) == m_lockscreenWallpaperPlugin) {
            return model->data(model->index(i), PlasmaQuick::ConfigModel::SourceRole).toString();
        }
    }

    return QString();
}

void WallpaperPlugin::setLockscreenWallpaperPlugin(const QString &wallpaperPlugin)
{
    KConfigGroup greeterGroup = m_lockscreenConfigFile->group(QStringLiteral("Greeter")).group(QStringLiteral("Wallpaper")).group(wallpaperPlugin);

    m_homescreenConfig = loadConfiguration(greeterGroup, wallpaperPlugin, true);
    m_lockscreenWallpaperPlugin = wallpaperPlugin;
    saveLockscreenSettings();

    Q_EMIT lockscreenWallpaperPluginChanged();
}

QCoro::Task<void> WallpaperPlugin::setHomescreenWallpaper(const QString &path)
{
    auto message = QDBusMessage::createMethodCall(QLatin1String("org.kde.plasmashell"),
                                                  QLatin1String("/PlasmaShell"),
                                                  QLatin1String("org.kde.PlasmaShell"),
                                                  QLatin1String("setWallpaper"));

    for (uint screen = 0; screen < qApp->screens().size(); screen++) {
        message.setArguments({"org.kde.image", QVariantMap{{"Image", path}}, screen});

        const QDBusReply<void> reply = co_await QDBusConnection::sessionBus().asyncCall(message);
        if (!reply.isValid()) {
            qWarning() << "Failed to set wallpaper for screen" << screen << ":" << reply.error();
        }
    }
}

void WallpaperPlugin::setLockscreenWallpaper(const QString &path)
{
    auto greeterGroup = m_lockscreenConfigFile->group(QStringLiteral("Greeter"))
                            .group(QStringLiteral("Wallpaper"))
                            .group(QStringLiteral("org.kde.image"))
                            .group(QStringLiteral("General"));
    greeterGroup.writeEntry("Image", path, KConfigGroup::Notify);

    greeterGroup = m_lockscreenConfigFile->group(QStringLiteral("Greeter"));
    greeterGroup.writeEntry("WallpaperPlugin", "org.kde.image", KConfigGroup::Notify);

    m_lockscreenConfigFile->sync();
}

QString WallpaperPlugin::homescreenWallpaperPath()
{
    return m_homescreenWallpaperPath;
}

QString WallpaperPlugin::lockscreenWallpaperPath()
{
    return m_lockscreenWallpaperPath;
}

QCoro::Task<void> WallpaperPlugin::loadHomescreenSettings()
{
    auto message = QDBusMessage::createMethodCall(QLatin1String("org.kde.plasmashell"),
                                                  QLatin1String("/PlasmaShell"),
                                                  QLatin1String("org.kde.PlasmaShell"),
                                                  QLatin1String("wallpaper"));
    message.setArguments({(uint)0}); // assume wallpaper on first screen

    QDBusReply<QVariantMap> reply = co_await QDBusConnection::sessionBus().asyncCall(message);
    if (!reply.isValid()) {
        qWarning() << "unable to load homescreen wallpaper settings:" << reply.error();
        co_return;
    }

    QVariantMap map = reply.value();
    m_homescreenWallpaperPath = QString{};

    if (!map.contains("wallpaperPlugin")) {
        qWarning() << "wallpaperPlugin not found in response from org.kde.PlasmaShell wallpaper(), could not retrieve wallpaper";
        Q_EMIT homescreenWallpaperPathChanged();
        co_return;
    }

    // load wallpaper plugin config
    if (m_homescreenConfig) {
        m_homescreenConfig->deleteLater();
    }
    m_homescreenConfig = new QQmlPropertyMap{this};

    for (const auto &key : map.keys()) {
        if (key != QStringLiteral("wallpaperPlugin")) {
            m_homescreenConfig->insert(key, map[key]);
        }
    }

    // get wallpaper plugin
    m_homescreenWallpaperPlugin = map["wallpaperPlugin"].toString();

    // parse image configuration
    if (m_homescreenWallpaperPlugin == QStringLiteral("org.kde.image")) {
        m_homescreenWallpaperPath = map["Image"].toString();
    }

    Q_EMIT homescreenConfigurationChanged();
    Q_EMIT homescreenWallpaperPluginChanged();
    Q_EMIT homescreenWallpaperPathChanged();
}

void WallpaperPlugin::loadLockscreenSettings()
{
    auto greeterGroup = m_lockscreenConfigFile->group(QStringLiteral("Greeter"));
    m_lockscreenWallpaperPlugin = greeterGroup.readEntry(QStringLiteral("WallpaperPlugin"), QString());
    m_lockscreenWallpaperPath = QString{};

    greeterGroup = m_lockscreenConfigFile->group(QStringLiteral("Greeter")).group(QStringLiteral("Wallpaper")).group(m_lockscreenWallpaperPlugin);

    m_lockscreenConfig = static_cast<QQmlPropertyMap *>(loadConfiguration(greeterGroup, m_lockscreenWallpaperPlugin, true));

    if (m_lockscreenWallpaperPlugin == QStringLiteral("org.kde.image")) {
        m_lockscreenWallpaperPath = greeterGroup.group(QStringLiteral("General")).readEntry(QStringLiteral("Image"), QString());
    }

    Q_EMIT lockscreenWallpaperPluginChanged();
    Q_EMIT lockscreenConfigurationChanged();
    Q_EMIT lockscreenWallpaperPathChanged();
}

QQmlPropertyMap *WallpaperPlugin::loadConfiguration(KConfigGroup group, QString wallpaperPlugin, bool loadDefaults)
{
    auto packages = KPackage::PackageLoader::self()->listPackages(QStringLiteral("Plasma/Wallpaper"), "plasma/wallpapers");
    KPackage::Package pkg;
    bool found = false;

    for (auto &metaData : packages) {
        if (metaData.pluginId() == wallpaperPlugin) {
            found = true;
            pkg = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/Wallpaper"), QFileInfo(metaData.fileName()).path());
            break;
        }
    }

    if (!found || !pkg.isValid()) {
        qWarning() << "Could not find wallpaper plugin" << wallpaperPlugin;
        return nullptr;
    }

    QFile file(pkg.fileUrl("config", "main.xml").toLocalFile());

    auto *configLoader = new KConfigLoader(group, &file, this);
    if (loadDefaults) {
        configLoader->setDefaults();
    }
    auto config = new KConfigPropertyMap(configLoader, this);
    return config;
}

QCoro::Task<void> WallpaperPlugin::saveHomescreenSettings()
{
    auto iface = new QDBusInterface("org.kde.plasmashell", "/PlasmaShell", "org.kde.PlasmaShell", QDBusConnection::sessionBus(), this);
    if (!iface->isValid()) {
        qWarning() << "Failed to connect to wallpaper dbus:" << qPrintable(QDBusConnection::sessionBus().lastError().message());
        co_return;
    }

    QVariantMap params;
    for (const auto &key : m_homescreenConfig->keys()) {
        params.insert(key, m_homescreenConfig->value(key).toString());
    }

    if (m_homescreenWallpaperPlugin == "org.kde.image") {
        params.remove("PreviewImage");
    }

    for (uint screen = 0; screen < qApp->screens().size(); screen++) {
        QList<QVariant> args = {m_homescreenWallpaperPlugin, params, screen};
        const QDBusReply<void> response = co_await iface->asyncCallWithArgumentList(QStringLiteral("setWallpaper"), args);
        if (!response.isValid()) {
            qWarning() << "Failed to set wallpaper:" << response.error();
        }
    }
}

void WallpaperPlugin::saveLockscreenSettings()
{
    auto greeterGroup = m_lockscreenConfigFile->group(QStringLiteral("Greeter"))
                            .group(QStringLiteral("Wallpaper"))
                            .group(m_lockscreenWallpaperPlugin)
                            .group(QStringLiteral("General"));
    for (const auto &key : m_lockscreenConfig->keys()) {
        greeterGroup.writeEntry(key, m_lockscreenConfig->value(key), KConfigGroup::Notify);
    }

    greeterGroup = m_lockscreenConfigFile->group(QStringLiteral("Greeter"));
    greeterGroup.writeEntry("WallpaperPlugin", m_lockscreenWallpaperPlugin, KConfigGroup::Notify);

    m_lockscreenConfigFile->sync();
}

WallpaperConfigModel::WallpaperConfigModel(QObject *parent)
    : PlasmaQuick::ConfigModel(parent)
{
    repopulate();
}

void WallpaperConfigModel::repopulate()
{
    clear();
    for (const KPluginMetaData &m : KPackage::PackageLoader::self()->listPackages(QStringLiteral("Plasma/Wallpaper"))) {
        KPackage::Package pkg = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/Wallpaper"), m.pluginId());
        if (!pkg.isValid()) {
            continue;
        }
        appendCategory(pkg.metadata().iconName(), pkg.metadata().name(), pkg.fileUrl("ui", QStringLiteral("config.qml")).toString(), m.pluginId());
    }
}

#include "wallpaperplugin.moc"
