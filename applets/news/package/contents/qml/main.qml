import Qt 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: page;
    Item {
      id:main
      Plasma.DataSource { id: dataSource; engine: "rss"; source: "http://www.kde.org/dotkdeorg.rdf "; interval: 50000; }
      resources: [
          Component {
              id: simpleText
              Text {
                  width: list.width
                  text: dataSource['items'][modelData].title
              }
          }
      ]
      Column {
        Text { text: 'Time Is ' + dataSource['title']; }

        ListView {
            id: list
            width: page.width
            height:page.height
            clip: true
            model: dataSource['items.count']
            delegate: simpleText
        }
      }
    }
}
