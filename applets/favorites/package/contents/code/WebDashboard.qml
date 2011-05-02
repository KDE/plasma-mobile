import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets


Item {
    width: 960
    height: 540

    PlasmaCore.Theme { id: theme }

    Column {
        anchors.fill: parent
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom; }

        Text {
            id: categoryLabel
            text: i18n("Favorites")
            color: theme.textColor
            font.pointSize: 24
            style: Text.Sunken;
            styleColor: theme.backgroundColor
        }
        PlasmaWidgets.Separator {
            width: categoryLabel.width * 1.1
            anchors.left: parent.left
        }

        Bookmarks {
            id: bookmarks
            width: parent.width
        }

        Text {
            id: recentlyViewedLabel
            text: i18n("Recently viewed")
            color: theme.textColor
            font.pointSize: 24
            style: Text.Sunken;
            styleColor: theme.backgroundColor
        }

        PlasmaWidgets.Separator {
            width: recentlyViewedLabel.width * 1.1
            anchors.left: parent.left
        }

        Bookmarks {
            id: history
            width: parent.width
        }


        Text {
            id: openPagesLabel
            text: i18n("Open pages")
            color: theme.textColor
            font.pointSize: 24
            style: Text.Sunken;
            styleColor: theme.backgroundColor
        }

        PlasmaWidgets.Separator {
            width: openPagesLabel.width * 1.1; anchors.left: parent.left
        }

        Bookmarks {
            id: tabs
            width: parent.width
        }
        /*
        Text {
            text: i18n("Recently visited...")
        }

        WebItemList {
            id: history
            width: parent.width
        }
        */
        Item {
            //color: theme.textColor; opacity: 0.3
        }
    }
}