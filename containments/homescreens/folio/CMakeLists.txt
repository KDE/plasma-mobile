# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.plasma.mobile.homescreen.folio\")

plasma_add_applet(org.kde.plasma.mobile.homescreen.folio
    QML_SOURCES
        qml/AppDrawer.qml
        qml/AppDrawerGrid.qml
        qml/AppDrawerHeader.qml
        qml/DelegateDragItem.qml
        qml/FavouritesBar.qml
        qml/FolderView.qml
        qml/FolderViewTitle.qml
        qml/FolioHomeScreen.qml
        qml/HomeScreenPage.qml
        qml/HomeScreenPages.qml
        qml/main.qml
        qml/PlaceholderDelegate.qml
        qml/WidgetDragItem.qml
        qml/config.qml
    CPP_SOURCES
        applicationlistmodel.cpp
        delegatetoucharea.cpp
        dragstate.cpp
        favouritesmodel.cpp
        folioapplication.cpp
        folioapplicationfolder.cpp
        foliodelegate.cpp
        foliosettings.cpp
        foliowidget.cpp
        homescreen.cpp
        homescreenstate.cpp
        pagelistmodel.cpp
        pagemodel.cpp
        widgetcontainer.cpp
        widgetsmanager.cpp
        windowlistener.cpp
)

ecm_target_qml_sources(org.kde.plasma.mobile.homescreen.folio SOURCES
    qml/delegate/AbstractDelegate.qml
    qml/delegate/AppDelegate.qml
    qml/delegate/AppFolderDelegate.qml
    qml/delegate/DelegateAppIcon.qml
    qml/delegate/DelegateFolderIcon.qml
    qml/delegate/DelegateIconLoader.qml
    qml/delegate/DelegateLabel.qml
    qml/delegate/DelegateShadow.qml
    qml/delegate/KeyboardHighlight.qml
    qml/delegate/WidgetDelegate.qml
    qml/delegate/WidgetDelegateConfig.qml
    PATH delegate
)

ecm_target_qml_sources(org.kde.plasma.mobile.homescreen.folio SOURCES
    qml/private/ConfirmDeleteFolderDialogLoader.qml
    qml/private/ContextMenuLoader.qml
    qml/private/DarkenEffect.qml
    qml/private/Orientation.qml
    qml/private/WidgetHandlePosition.qml
    qml/private/WidgetResizeHandle.qml
    qml/private/WidgetResizeHandleFrame.qml
    PATH private
)

ecm_target_qml_sources(org.kde.plasma.mobile.homescreen.folio SOURCES
    qml/settings/AppletListViewer.qml
    qml/settings/SettingsButton.qml
    qml/settings/SettingsComponent.qml
    qml/settings/ConfigGeneral.qml
    PATH settings
)

target_link_libraries(org.kde.plasma.mobile.homescreen.folio PRIVATE
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Plasma::Plasma
    Plasma::PlasmaQuick
    KF6::I18n
    KF6::Service
    KF6::KIOGui
    KF6::Notifications
    Plasma::KWaylandClient
    KF6::WindowSystem
    KF6::JobWidgets
)
