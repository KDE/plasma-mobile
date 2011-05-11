import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents


Item {
    width: 960
    height: 540

    y: 56

    PlasmaCore.Theme { id: theme }

    Column {
        id: mainList
        anchors.fill: parent

        Text {
            id: bookmarksLabel
            text: i18n("Favorites")
            color: theme.textColor
            font.pointSize: 24
            style: Text.Sunken;
            styleColor: theme.backgroundColor
        }
        PlasmaWidgets.Separator {
            width: bookmarksLabel.width * 1.1
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
    }

    NewBookmark {
        id: newBookmark
        width: parent.width / 4
        height: parent.height / 4
        //height: 64
        //y: 64
        x: parent.width-width
        anchors.top: parent.top
        //anchors.right: parent.right
    }

}