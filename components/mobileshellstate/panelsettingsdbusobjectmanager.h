// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QString>
#include <qqmlregistration.h>

#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>

#include <kscreen/config.h>

class PanelSettingsDBusObject;

class PanelSettingsDBusObjectManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PanelSettingsDBusObjectManager(QObject *parent = nullptr);

    // called by QML
    Q_INVOKABLE void registerObjects();

private:
    bool m_initialized = false;
    QList<PanelSettingsDBusObject *> m_dbusObjects;
    KScreen::ConfigPtr m_kscreenConfig{nullptr};
};

class PanelSettingsDBusObject : public QObject
{
    Q_OBJECT
    // HACK: org.kde.plasmashell prefix seems to bug out and not compile with the qt macro, use this for now
    Q_CLASSINFO("D-Bus Interface", "org.kde.plasmashellMobilePanels")

public:
    PanelSettingsDBusObject(QObject *parent = nullptr);

    void registerObject(KScreen::OutputPtr output);

    int outputId() const;
    QString outputName() const;

Q_SIGNALS:
    Q_SCRIPTABLE void statusBarHeightChanged();
    Q_SCRIPTABLE void statusBarLeftPaddingChanged();
    Q_SCRIPTABLE void statusBarRightPaddingChanged();
    Q_SCRIPTABLE void statusBarCenterSpacingChanged();
    Q_SCRIPTABLE void navigationPanelHeightChanged();
    Q_SCRIPTABLE void navigationPanelLeftPaddingChanged();
    Q_SCRIPTABLE void navigationPanelRightPaddingChanged();

public Q_SLOTS:
    Q_SCRIPTABLE qreal statusBarHeight() const;
    Q_SCRIPTABLE qreal statusBarLeftPadding() const;
    Q_SCRIPTABLE qreal statusBarRightPadding() const;
    Q_SCRIPTABLE qreal statusBarCenterSpacing() const;

    Q_SCRIPTABLE qreal navigationPanelHeight() const;
    Q_SCRIPTABLE qreal navigationPanelLeftPadding() const;
    Q_SCRIPTABLE qreal navigationPanelRightPadding() const;

private:
    void updateFields();

    void setStatusBarHeight(qreal statusBarHeight);
    void setStatusBarLeftPadding(qreal statusBarLeftPadding);
    void setStatusBarRightPadding(qreal statusBarRightPadding);
    void setStatusBarCenterSpacing(qreal statusBarCenterSpacing);

    void setNavigationPanelHeight(qreal navigationPanelHeight);
    void setNavigationPanelLeftPadding(qreal navigationPanelLeftPadding);
    void setNavigationPanelRightPadding(qreal navigationPanelRightPadding);

    int m_outputId = -1;
    QString m_outputName;

    qreal m_statusBarHeight = -1;
    qreal m_statusBarLeftPadding = 0;
    qreal m_statusBarRightPadding = 0;
    qreal m_statusBarCenterSpacing = 0;
    qreal m_navigationPanelHeight = -1;
    qreal m_navigationPanelLeftPadding = 0;
    qreal m_navigationPanelRightPadding = 0;

    KSharedConfig::Ptr m_config;
    KConfigWatcher::Ptr m_configWatcher;
    KScreen::OutputPtr m_output;
};
