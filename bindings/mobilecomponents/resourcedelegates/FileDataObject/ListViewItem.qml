 
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
 
Item {
            id: resourceItem
            height: 72
            width: 400

            Item {
                id: itemFrame
                anchors {   bottom: parent.bottom;
                            top: parent.top;
                            left: parent.left;
                            right: parent.right;
                            margins: 24;
                }
                //height: 128
                height: resourceItem.height
                //frameShadow: "Raised"

                PlasmaWidgets.IconWidget {
                    id: previewImage
                    //anchors.fill: item
                    //source: model.data[DataEngineSource]["fileName"]
                    //source: fileName
                    //source: fileName
                    //source: "/home/sebas/Documents/wallpaper.png"
                    height:64
                    width: 64
                    anchors.margins: 8
                    Component.onCompleted: {
                        print("Setting icon " + "nepomuk");
                        setIcon("nepomuk");
                    }
                }

                PlasmaWidgets.Label {
                    id: previewLabel
                    text: label
                    //text: url
                    font.pixelSize: 14
                    font.bold: true
                    height: 30

                    width: parent.width - previewImage.width
                    anchors.top: itemFrame.top
                    //anchors.bottom: infoLabel.top;
                    anchors.left: previewImage.right
                    anchors.right: itemFrame.right
                    anchors.margins: 8

                }

                PlasmaWidgets.Label {
                    id: infoLabel
                    //image: metadataSource.data[DataEngineSource]["fileName"]
                    //text: "the long and winding road..."
                    text: { 
                        if (lastModified) {
                            lastModified.toString()
                        } else {
                            className
                        }
                    }
                    opacity: 0.6
                    //font.pixelSize: font.pixelSize * 1.8
                    font.pixelSize: 11
                    height: 14
                    width: parent.width - previewImage.width
                    //wrapMode: Text.Wrap
                    anchors.right: itemFrame.right
                    anchors.top: previewLabel.bottom
                    anchors.bottom: itemFrame.bottom
                    anchors.left: previewImage.right
                    anchors.margins: 8

                }
            }
        }