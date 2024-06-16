<!--
- SPDX-FileCopyrightText: None
- SPDX-License-Identifier: CC0-1.0
-->

# Folio Homescreen

This is the paged homescreen for Plasma Mobile.

### How it works

Most of the homescreen is in C++ in order to keep logic together, with QML only responsible for the display and user input.

As such, all the positioning and placement of delegates on the screen are top down from the model, as well as drag and drop behaviour.

#### TODO
- BUG: If an app gets uninstalled, the homescreen UI needs to ensure that delegates are updated
- BUG: landscape favourites bar duplication when dragging icon from it sometimes
- BUG: can't insert delegates in-between very well in landscape favourites bar
- BUG: drag and drop animation when rejected on a different page
- IMPROVEMENT: can make the touch area only the icon?
- FEATURE: Add folio/halcyon switcher in initial-start
- FEATURE: add widget import/export
- FEATURE: keyboard navigation
- FEATURE: touchpad navigation
- FEATURE: option to darken wallpaper
- FEATURE: option to turn off row/column swap
- PERFORMANCE: ensure that the widget config overlays are in loaders
