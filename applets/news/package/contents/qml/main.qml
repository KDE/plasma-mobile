import Qt 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: page;
    Item {
      id:main
      Plasma.DataSource { id: dataSource; engine: "rss"; source: "http://planetkde.org/rss20.xml"; interval: 50000; }
      resources: [
          Component {
              id: simpleText
              Text {
                  width: list.width
                  text: dataSource['items'][modelData].title
                  MouseArea {
                      id: itemMouse
                      anchors.fill: parent
                      onClicked: {
                          list.currentIndex = index
                          bodyView.html = dataSource['items'][modelData].description
                          list.itemClicked()
                      }
                  }
              }
          },
          Component {
              id: detailsItem
              Item {
                id: bodyViewContainer
                Plasma.WebView {
                    id : bodyView
                    width : details.width
                    height: details.height
                    x: bodyViewContainer.x
                    dragToScroll : true
                    html: dataSource['items'][modelData].description
                }
              }
          }
      ]

        Plasma.TabBar {
            id : mainView
            width : page.width
            height: page.height
            //tabBarShown: false

            QGraphicsWidget {
                id: listContainer
                ListView {
                    id: list
                    anchors.fill: listContainer
                    signal itemClicked;

                    clip: true
                    model: dataSource['items.count']
                    delegate: simpleText
                }
            }
            Plasma.WebView {
                id : bodyView
                dragToScroll : true
            }
        }

        Connections {
            target: list
            onItemClicked: mainView.currentIndex = 1
        }
    }
}
