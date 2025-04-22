#pragma once

#include <QObject>

#include <KPackage/PackageLoader>

#include <KPluginMetaData>
#include <QQmlComponent>

class QuickSettingsTest : public QObject
{
    Q_OBJECT

public:
    QuickSettingsTest(QObject *object = nullptr);

    void load();
    void loadAll();
    void loadQuickSetting(KPluginMetaData package);

    void list() const;

private Q_SLOTS:
    void afterQuickSettingLoad(QQmlEngine *engine, KPluginMetaData metaData, QQmlComponent *component);

private:
    QList<KPluginMetaData> m_packages;
    QQmlEngine *m_engine;
    QList<QString> m_messages;
};