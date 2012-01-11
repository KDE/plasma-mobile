function placeLinkPopup(mouse) {
    // Find the root item, then map our cursor position to it
    // in order to check if the edit bubble could end up off-screen
    var rootItem = parent;
    while (rootItem.parent) {
        rootItem = rootItem.parent;
    }
    var distanceToTop = webView.mapToItem(rootItem, mouse.x, mouse.y);
    print( "   distanceToTop: " + distanceToTop.x);
    if (distanceToTop.x < linkPopup.width/2) {
        // hitting the left edge
        //linkPopup.x = mouse.x

    } else {
        linkPopup.x = mouse.x-(linkPopup.width/2)
    }
    if (distanceToTop.y > linkPopup.height + header.height*2) {
        linkPopup.y = mouse.y-linkPopup.height
    } else {
        //linkPopup.y = mouse.y-(linkPopup.width/2)
    }

}
