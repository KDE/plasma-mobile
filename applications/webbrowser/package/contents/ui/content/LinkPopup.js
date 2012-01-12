function placeLinkPopup(mouse) {
    // Find the root item, then map our cursor position to it
    // in order to check if the edit bubble could end up off-screen
    var rootItem = parent;
    while (rootItem.parent) {
        rootItem = rootItem.parent;
    }
    var distanceToTop = webView.mapToItem(rootItem, mouse.x, mouse.y);
    //var distanceToTop = mouse;
    print( "   distanceToTop: " + distanceToTop.x);
    print( " mouse: x: " + mouse.x + " y: " + mouse.y);
    if (distanceToTop.x < linkPopup.width/2) {
        print(" hitting the left edge " + distanceToTop.x);
        //linkPopup.x = mouse.x

    } else {
        linkPopup.x = mouse.x-(linkPopup.width/2)
    }
    if (distanceToTop.y > linkPopup.height + header.height) {
        print(" placing at mouse.y : " + mouse.y + " " + linkPopup.height)
        linkPopup.y = mouse.y;
    } else {
        //linkPopup.y = mouse.y-(linkPopup.width/2)
    }

}
