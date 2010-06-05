import Qt 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: page;
    Item {
      Plasma.DataSource { id: dataSource; engine: "rss"; source: "http://www.kde.org/dotkdeorg.rdf "; interval: 50000; }
      resources: [
          Component {
              id: simpleText
              Text {
                  //text: modelData
                  text: dataSource['items'][modelData].title
              }
          }
      ]
      Column {
        Text { text: 'Time Is ' + dataSource['title']; }
        Text { text: "Available Data:"; }
        Repeater { model: dataSource['items.count']; delegate: simpleText; }
      }
    }
}
