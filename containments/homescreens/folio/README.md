<!--
- SPDX-FileCopyrightText: None
- SPDX-License-Identifier: CC0-1.0
-->

# Folio Homescreen

This is the paged homescreen for Plasma Mobile.

### How it works

Most of the homescreen is in C++ in order to keep logic together, with QML only responsible for the display and user input.

As such, all of the positioning and placement of delegates on the screen are top down from the model, as well as drag and drop behaviour.

#### TODO
- Add folio/halcyon switcher in initial-start
- If an app gets uninstalled, the homescreen UI needs to ensure that delegates are updated
- BUG: the position of where things think the dragged icon is during drag-and-drop is slightly off because of the label
- BUG: landscape favourites bar duplication when dragging icon from it sometimes
- BUG: can't insert delegates in-between very well in landscape favourites bar
- can make the touch area only the icon?
- FEATURE: add import/export
- FEATURE: keyboard navigation
- FEATURE: touchpad navigation
- BUG: it's possible to get stuck in an unswipeable state after swiping down from the app drawer
