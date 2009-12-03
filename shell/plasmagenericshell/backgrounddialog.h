/*
  Copyright (c) 2007 Paolo Capriotti <p.capriotti@gmail.com>
  Copyright (c) 2008 by Petri Damsten <damu@iki.fi>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
*/

#ifndef BACKGROUNDDIALOG_H
#define BACKGROUNDDIALOG_H

#include <KConfigDialog>

#include "plasmagenericshell_export.h"

namespace Plasma {
    class Wallpaper;
    class Containment;
    class View;
}
class QStandardItemModel;
class ScreenPreviewWidget;

// WallpaperWidget is passed the wallpaper
// in createConfigurationInterface so it can notify
// of changes (used to enable the apply button)
class PLASMAGENERICSHELL_EXPORT WallpaperWidget :public QWidget
{
    Q_OBJECT
public:
      WallpaperWidget(QWidget *parent) :QWidget(parent) {}

signals:
    void modified(bool isModified);

public slots:
    void settingsChanged(bool isModified);
};

class BackgroundDialogPrivate;
class PLASMAGENERICSHELL_EXPORT BackgroundDialog : public KConfigDialog
{
    Q_OBJECT
public:
    BackgroundDialog(const QSize &res, Plasma::Containment *containment,
                     Plasma::View *view, QWidget* parent, const QString &id,
                     KConfigSkeleton *s);
    ~BackgroundDialog();

    void reloadConfig();

signals:
    void containmentPluginChanged(Plasma::Containment *c);

public slots:
    void saveConfig();

protected:
    virtual bool hasChanged();

private:
    KConfigGroup wallpaperConfig(const QString &plugin);

private slots:
    void changeBackgroundMode(int mode);
    void cleanup();
    void checkActivityName();
    void settingsModified(bool modified = true);

private:
    BackgroundDialogPrivate *d;
};

#endif // BACKGROUNDDIALOG_H
