// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.plasma.private.mobileshell as MobileShell

Loader {
    id: root
    property Folio.HomeScreen folio
    property MobileShell.MaskManager maskManager

    height: folio.FolioSettings.delegateIconSize
    width: folio.FolioSettings.delegateIconSize

    property Folio.FolioDelegate delegate

    sourceComponent: {
        if (!delegate) {
            return noIcon;
        } else if (delegate.type === Folio.FolioDelegate.Application) {
            return appIcon;
        } else if (delegate.type === Folio.FolioDelegate.Folder) {
            return folderIcon;
        } else {
            return noIcon;
        }
    }

    Component {
        id: noIcon
        Item {}
    }

    Component {
        id: appIcon

        DelegateAppIcon {
            folio: root.folio
            source: delegate.application.icon
        }
    }

    Component {
        id: folderIcon

        DelegateFolderIcon {
            folio: root.folio
            maskManager: root.maskManager
            folder: delegate.folder
        }
    }
}
