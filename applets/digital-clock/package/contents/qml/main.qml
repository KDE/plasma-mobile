import Qt 4.7
import Plasma 0.1 as Plasma

QGraphicsWidget {
    id: page;
    Item {
      Plasma.DataSource { id: dataSource; engine: "time"; source: "Local"; interval: 500; }
      resources: [
          Component {
              id: simpleText
              Text {
                  text: modelData + ': ' + dataSource[modelData]
              }
          }
      ]
      Column {
        Text { text: 'Time Is ' + dataSource['time']; }
        Text { text: "Available Data:"; }
        Repeater { model: dataSource.keys; delegate: simpleText; }
      }
    }
}
