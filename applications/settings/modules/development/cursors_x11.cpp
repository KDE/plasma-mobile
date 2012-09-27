/*
 *  Copyright © 2003-2007 Fredrik Höglund <fredrik@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "develsettingsplugin.h"

#include <QCursor>
#include <QFile>
#include <QImage>
#include <QPixmap>
#include <QX11Info>

#include <KConfig>
#include <KConfigGroup>
#include <KGlobalSettings>
#include <KToolInvocation>
#include <klauncher_iface.h>

#include "legacycursorbitmaps.h"

#include <X11/cursorfont.h>
#include <X11/Xlib.h>
#include <X11/Xlibint.h>
#include <X11/Xcursor/Xcursor.h>
#include <X11/Xutil.h>
#include <X11/extensions/Xfixes.h>

// lifted and adapted from kde-workspace/kcontrol/input/xcursor/

struct CursorBitmap
{
    CursorBitmap(const char * const *xpm, const QPoint &hotspot)
        : xpm(xpm), hotspot(hotspot) {}
    const char * const *xpm;
    QPoint hotspot;
};

struct CursorMetrics
{
    int xhot, yhot;
    int width, height;
};

XFontStruct *xfs = NULL;

struct _XcursorImage;
struct _XcursorImages;

typedef _XcursorImage XcursorImage;
typedef _XcursorImages XcursorImages;

namespace {

    // Borrowed from xc/lib/Xcursor/library.c
    static const char * const standard_names[] = {
        /* 0 */
        "X_cursor",         "arrow",            "based_arrow_down",     "based_arrow_up",
        "boat",             "bogosity",         "bottom_left_corner",   "bottom_right_corner",
        "bottom_side",      "bottom_tee",       "box_spiral",           "center_ptr",
        "circle",           "clock",            "coffee_mug",           "cross",

        /* 32 */
        "cross_reverse",    "crosshair",        "diamond_cross",        "dot",
        "dotbox",           "double_arrow",     "draft_large",          "draft_small",
        "draped_box",       "exchange",         "fleur",                "gobbler",
        "gumby",            "hand1",            "hand2",                "heart",

        /* 64 */
        "icon",             "iron_cross",       "left_ptr",             "left_side",
        "left_tee",         "leftbutton",       "ll_angle",             "lr_angle",
        "man",              "middlebutton",     "mouse",                "pencil",
        "pirate",           "plus",             "question_arrow",       "right_ptr",

        /* 96 */
        "right_side",       "right_tee",        "rightbutton",          "rtl_logo",
        "sailboat",         "sb_down_arrow",    "sb_h_double_arrow",    "sb_left_arrow",
        "sb_right_arrow",   "sb_up_arrow",      "sb_v_double_arrow",    "shuttle",
        "sizing",           "spider",           "spraycan",             "star",

        /* 128 */
        "target",           "tcross",           "top_left_arrow",       "top_left_corner",
        "top_right_corner", "top_side",         "top_tee",              "trek",
        "ul_angle",         "umbrella",         "ur_angle",             "watch",
        "xterm",
    };
}

CursorMetrics cursorMetrics(int shape)
{
    CursorMetrics metrics;	

    if (!xfs) {
        return metrics;
    }

    // Get the metrics for the mask glyph
    XCharStruct xcs = xfs->per_char[shape + 1];

    // Compute the width, height and cursor hotspot from the glyph metrics.
    // Note that the X11 definition of right bearing is the right-ward distance
    // from the X origin to the X coordinate of the rightmost pixel in the glyph.
    // In QFontMetrics the right bearing is defined as the left-ward distance
    // from the X origin of the hypothetical subsequent glyph to the X coordinate
    // of the rightmost pixel in this glyph.
    metrics.width  = xcs.rbearing - xcs.lbearing;
    metrics.height = xcs.ascent   + xcs.descent;

    // The cursor hotspot is defined as the X and Y origin of the glyph.
    if (xcs.lbearing < 0) {
        metrics.xhot = -xcs.lbearing;
        if (xcs.rbearing < 0)           // rbearing can only be < 0 when lbearing < 0
            metrics.width -= xcs.rbearing;
    } else {                            // If the ink starts to the right of the X coordinate.
        metrics.width += xcs.lbearing;  // With cursors this is probably never the case in practice,
        metrics.xhot = 0;               // since it would put the hotspot outside the image.
    }

    if (xcs.ascent > 0) {
        metrics.yhot = xcs.ascent;
        if (xcs.descent < 0)            // descent can only be < 0 when ascent > 0
            metrics.height -= xcs.descent;
    } else {                            // If the ink starts below the baseline.
        metrics.height -= xcs.ascent;   // With cursors this is probably never the case in practice,
        metrics.yhot = 0;               // since it would put the hotspot outside the image.
    }

    return metrics;
}


int cursorShape(const QString &name)
{
    static QHash<QString, int> shapes;
    // A font cursor is created from two glyphs; a shape glyph and a mask glyph
    // stored in pairs in the font, with the shape glyph first. There's only one
    // name for each pair. This function always returns the index for the
    // shape glyph.
    if (shapes.isEmpty())
    {
        int num = XC_num_glyphs / 2;
        shapes.reserve(num + 5);

        for (int i = 0; i < num; ++i)
            shapes.insert(standard_names[i], i << 1);

        // Qt uses alternative names for some core cursors
        shapes.insert("size_all",      XC_fleur);
        shapes.insert("up_arrow",      XC_center_ptr);
        shapes.insert("ibeam",         XC_xterm);
        shapes.insert("wait",          XC_watch);
        shapes.insert("pointing_hand", XC_hand2);
    }

    return shapes.value(name, -1);
}

QString findAlternative(const QString &name)
{
    static QHash<QString, QString> alternatives;
    if (alternatives.isEmpty())
    {
        alternatives.reserve(18);

        // Qt uses non-standard names for some core cursors.
        // If Xcursor fails to load the cursor, Qt creates it with the correct name using the
        // core protcol instead (which in turn calls Xcursor). We emulate that process here.
        // Note that there's a core cursor called cross, but it's not the one Qt expects.
        alternatives.insert("cross",          "crosshair");
        alternatives.insert("up_arrow",       "center_ptr");
        alternatives.insert("wait",           "watch");
        alternatives.insert("ibeam",          "xterm");
        alternatives.insert("size_all",       "fleur");
        alternatives.insert("pointing_hand",  "hand2");

        // Precomputed MD5 hashes for the hardcoded bitmap cursors in Qt and KDE.
        // Note that the MD5 hash for left_ptr_watch is for the KDE version of that cursor.
        alternatives.insert("size_ver",       "00008160000006810000408080010102");
        alternatives.insert("size_hor",       "028006030e0e7ebffc7f7070c0600140");
        alternatives.insert("size_bdiag",     "c7088f0f3e6c8088236ef8e1e3e70000");
        alternatives.insert("size_fdiag",     "fcf1c3c7cd4491d801f1e1c78f100000");
        alternatives.insert("whats_this",     "d9ce0ab605698f320427677b458ad60b");
        alternatives.insert("split_h",        "14fef782d02440884392942c11205230");
        alternatives.insert("split_v",        "2870a09082c103050810ffdffffe0204");
        alternatives.insert("forbidden",      "03b6e0fcb3499374a867c041f52298f0");
        alternatives.insert("left_ptr_watch", "3ecb610c1bf2410f44200f48c40d3599");
        alternatives.insert("hand2",          "e29285e634086352946a0e7090d73106");
        alternatives.insert("openhand",       "9141b49c8149039304290b508d208c40");
        alternatives.insert("closedhand",     "05e88622050804100c20044008402080");
    }

    return alternatives.value(name, QString());
}

QImage bitmapImage(const QString &name, int *xhot_return, int *yhot_return)
{
    static QHash<QString, CursorBitmap*> bitmaps;
    const CursorBitmap *bitmap;
    QImage image;

    if (bitmaps.isEmpty())
    {
        // These bitmap images are created from the XPM's in bitmaps.h.
        bitmaps.reserve(13);
        bitmaps.insert("size_ver",       new CursorBitmap(size_ver_xpm,   QPoint( 8,  8)));
        bitmaps.insert("size_hor",       new CursorBitmap(size_hor_xpm,   QPoint( 8,  8)));
        bitmaps.insert("size_bdiag",     new CursorBitmap(size_bdiag_xpm, QPoint( 8,  8)));
        bitmaps.insert("size_fdiag",     new CursorBitmap(size_fdiag_xpm, QPoint( 8,  8)));
        bitmaps.insert("left_ptr_watch", new CursorBitmap(busy_xpm,       QPoint( 0,  0)));
        bitmaps.insert("forbidden",      new CursorBitmap(forbidden_xpm,  QPoint(10, 10)));
        //bitmaps.insert("hand2",          new CursorBitmap(kde_hand_xpm,   QPoint( 7,  0)));
        //bitmaps.insert("pointing_hand",  new CursorBitmap(kde_hand_xpm,   QPoint( 7,  0)));
        bitmaps.insert("whats_this",     new CursorBitmap(whats_this_xpm, QPoint( 0,  0)));
        bitmaps.insert("split_h",        new CursorBitmap(split_h_xpm,    QPoint(16, 16)));
        bitmaps.insert("split_v",        new CursorBitmap(split_v_xpm,    QPoint(16, 16)));
        bitmaps.insert("openhand",       new CursorBitmap(openhand_xpm,   QPoint( 8,  8)));
        bitmaps.insert("closedhand",     new CursorBitmap(closedhand_xpm, QPoint( 8,  8)));
    }

    if ((bitmap = bitmaps.value(name)))
    {
        image = QPixmap(bitmap->xpm).toImage()
                .convertToFormat(QImage::Format_ARGB32_Premultiplied);

        // Return the hotspot to the caller
        if (xhot_return)
            *xhot_return = bitmap->hotspot.x();

        if (yhot_return)
            *yhot_return = bitmap->hotspot.y();
    }	

    return image;
}

QImage fontImage(const QString &name, int *xhot_return, int *yhot_return)
{
    // Note that the reason we need this function is that XcursorLibraryLoadImage()
    // doesn't work with the core theme, and X11 doesn't provide any other means to
    // obtain the image of a cursor other than that of the active one.
    Display *dpy = QX11Info::display();
    QImage image;

    Q_ASSERT(name.length() > 0);

    // Make sure the cursor font is loaded
    if (dpy->cursor_font == None)
        dpy->cursor_font = XLoadFont(dpy, CURSORFONT);

    // Query the font metrics for the cursor font
    if (dpy->cursor_font && !xfs)
        xfs = XQueryFont(dpy, dpy->cursor_font);

    // Get the glyph shape index for the cursor name
    int shape = cursorShape(name);

    // If we there's no matching cursor in the font, if the font couldn't be loaded,
    // or the font metrics couldn't be queried, return a NULL image.
    if (shape == -1 || dpy->cursor_font == None || xfs == NULL)
        return image;

    // Get the cursor metrics for the shape
    CursorMetrics m = cursorMetrics(shape);

    // Get the 16 bit bitmap and mask glyph indexes
    char source2b[2], mask2b[2];
    source2b[0] = uchar(shape >> 8);
    source2b[1] = uchar(shape & 0xff);

    mask2b[0] = uchar((shape + 1) >> 8);
    mask2b[1] = uchar((shape + 1) & 0xff);

    // Create an 8 bit pixmap and draw the glyphs on the pixmap
    Pixmap pm = XCreatePixmap(dpy, QX11Info::appRootWindow(), m.width, m.height, 8);
    GC gc = XCreateGC(dpy, pm, 0, NULL);
    XSetFont(dpy, gc, dpy->cursor_font);

    enum Colors { BackgroundColor = 0, MaskColor = 1, ShapeColor = 2 };

    // Clear the pixmap to transparent
    XSetForeground(dpy, gc, BackgroundColor);
    XFillRectangle(dpy, pm, gc, 0, 0, m.width, m.height);

    // Draw the mask
    XSetForeground(dpy, gc, MaskColor);
    XDrawString16(dpy, pm, gc, m.xhot, m.yhot, (XChar2b*)mask2b, 1);

    // Draw the shape
    XSetForeground(dpy, gc, ShapeColor );
    XDrawString16(dpy, pm, gc, m.xhot, m.yhot, (XChar2b*)source2b, 1);
    XFreeGC(dpy, gc);

    // Convert the pixmap to an XImage
    XImage *ximage = XGetImage(dpy, pm, 0, 0, m.width, m.height, AllPlanes, ZPixmap);
    XFreePixmap(dpy, pm);

    // Background color, mask color, shape color
    static const quint32 color[] =
    {
        0x00000000, // black, fully transparent
        0xffffffff, // white, fully opaque
        0xff000000, // black, fully opaque
    };

    // Convert the XImage to a QImage
    image = QImage(ximage->width, ximage->height, QImage::Format_ARGB32_Premultiplied);
    for (int y = 0; y < ximage->height; y++)
    {
        quint8  *s = reinterpret_cast<quint8*>(ximage->data + (y * ximage->bytes_per_line));
        quint32 *d = reinterpret_cast<quint32*>(image.scanLine(y));

        for (int x = 0; x < ximage->width; x++)
            *(d++) = color[*(s++)];
    }

    // Free the XImage
    free(ximage->data);
    ximage->data = NULL;
    XDestroyImage(ximage);

    // Return the cursor hotspot to the caller
    if (xhot_return)
        *xhot_return = m.xhot;

    if (yhot_return)
        *yhot_return = m.yhot;

    return image;
}



// ---------------------------------------------------------------------------

XcursorImages *xcLoadImages(const QByteArray &name, const QString &image, int size)
{
    QByteArray cursorName = QFile::encodeName(image);
    QByteArray themeName  = QFile::encodeName(name);

    return XcursorLibraryLoadImages(cursorName, themeName, size);
}

QCursor loadCursor(const QByteArray &themeName, const QString &name, int size)
{
    // Load the cursor images
    QByteArray name_b = name.toLocal8Bit();
    XcursorImages *images = xcLoadImages(themeName, name_b, size);

    if (!images) {
        images = xcLoadImages(themeName, findAlternative(name).toLocal8Bit(), size);
    }

    QCursor cursor;
    if (images) {
        // Create the cursor
        Cursor handle = XcursorImagesLoadCursor(QX11Info::display(), images);
        cursor = QCursor(Qt::HANDLE(handle)); // QCursor takes ownership of the handle
        XcursorImagesDestroy(images);
    } else {
        // Fall back to a legacy cursor
        QImage image;
        int xhot = 0, yhot = 0;

        // Try to load the image from a bitmap first
        image = bitmapImage(name, &xhot, &yhot);

        // If that fails, try to load it from the cursor font
        if (image.isNull()) {
            image = fontImage(name, &xhot, &yhot);
        }

        // Return the default cursor if that fails as well
        if (!image.isNull()) {
            QPixmap pixmap = QPixmap::fromImage(image);
            cursor = QCursor(pixmap, xhot, yhot);
        }
    }

    XFixesSetCursorName(QX11Info::display(), cursor.handle(), QFile::encodeName(name));
    return cursor;
}

void DevelSettings::applyCursorTheme(const QByteArray &themeName)
{
    // Require the Xcursor version that shipped with X11R6.9 or greater, since
    // in previous versions the Xfixes code wasn't enabled due to a bug in the
    // build system (freedesktop bug #975).

    // first check that we can actually do anything useful here by checking the version
    // of XFixes we have
    int event_base, error_base;
    if (XFixesQueryExtension(QX11Info::display(), &event_base, &error_base)) {
        int major, minor;
        XFixesQueryVersion(QX11Info::display(), &major, &minor);
        if (major < 2) {
            return;
        }
    }

    KConfig c("kcminputrc");
    KConfigGroup cg(&c, "Mouse");
    cg.writeEntry("cursorTheme", themeName);
    cg.sync();

    int size = cg.readEntry("cursorSize", 0);
    if (size < 1) {
        /* This code is basically borrowed from display.c of the XCursor library
           We can't use "int XcursorGetDefaultSize(Display *dpy)" because if
           previously the cursor size was set to a custom value, it would return
           this custom value. */
        int dpi = 0;
        Display *dpy = QX11Info::display();
        // The string "v" is owned and will be destroyed by Xlib
        char *v = XGetDefault(dpy, "Xft", "dpi");
        if (v) {
            dpi = atoi(v);
            if (dpi) {
                size = dpi * 16 / 72;
            }
        }

        if (size < 1) {
            int dim;
            if (DisplayHeight(dpy, DefaultScreen(dpy)) < DisplayWidth(dpy, DefaultScreen(dpy))) {
                dim = DisplayHeight(dpy, DefaultScreen(dpy));
            } else {
                dim = DisplayWidth(dpy, DefaultScreen(dpy));
            }
            size = dim / 48;
        }
    }

    // Set up the proper launch environment for newly started apps
    KToolInvocation::klauncher()->setLaunchEnv("XCURSOR_THEME", themeName);

    // Update the Xcursor X resources
    //runRdb(0);

    // Notify all applications that the cursor theme has changed
    KGlobalSettings::self()->emitChange(KGlobalSettings::CursorChanged);

    // Reload the standard cursors
    QStringList names;

    // Qt cursors
    names << "left_ptr"       << "up_arrow"      << "cross"      << "wait"
          << "left_ptr_watch" << "ibeam"         << "size_ver"   << "size_hor"
          << "size_bdiag"     << "size_fdiag"    << "size_all"   << "split_v"
          << "split_h"        << "pointing_hand" << "openhand"
          << "closedhand"     << "forbidden"     << "whats_this" << "copy" << "move" << "link";

    // X core cursors
    names << "X_cursor"            << "right_ptr"           << "hand1"
          << "hand2"               << "watch"               << "xterm"
          << "crosshair"           << "left_ptr_watch"      << "center_ptr"
          << "sb_h_double_arrow"   << "sb_v_double_arrow"   << "fleur"
          << "top_left_corner"     << "top_side"            << "top_right_corner"
          << "right_side"          << "bottom_right_corner" << "bottom_side"
          << "bottom_left_corner"  << "left_side"           << "question_arrow"
          << "pirate";

    foreach (const QString &name, names) {
        QCursor cursor = loadCursor(themeName, name, size);
        XFixesChangeCursorByName(QX11Info().display(), cursor.handle(), QFile::encodeName(name));
    }
}

QString DevelSettings::cursorTheme() const
{
    KConfig c("kcminputrc");
    KConfigGroup cg(&c, "Mouse");
    return cg.readEntry("cursorTheme", QString());
}

