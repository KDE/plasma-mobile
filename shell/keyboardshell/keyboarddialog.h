/*
 *   Copyright 2007-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2,
 *   or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef KEYBOARDDIALOG_H
#define KEYBOARDDIALOG_H


#include <Plasma/Dialog>
#include <Plasma/Plasma>

namespace Plasma
{
    class Containment;
    class Applet;
    class Corona;
} // namespace Plasma

class KeyboardDialog;

class KeyboardDialog : public Plasma::Dialog
{
    Q_OBJECT

public:
    KeyboardDialog(Plasma::Corona *corona, Plasma::Containment *containment, const QString &pluginName, int appletId, const QVariantList &appletArgs, QWidget *parent=0);
    ~KeyboardDialog();


    Plasma::Applet *applet();
    Plasma::Location location() const;
    Plasma::FormFactor formFactor() const;

    void setRotation(const int rotation);
    int rotation() const;

    void setDirection(const Plasma::Direction direction);
    Plasma::Direction direction() const;
    QSize transformedSize() const;

public Q_SLOTS:
    void setContainment(Plasma::Containment *containment);
    void updateGeometry();

Q_SIGNALS:
    void locationChanged(const KeyboardDialog *view);
    void geometryChanged();
    void containmentActivated();
    void storeApplet(Plasma::Applet *applet);

protected:
    void resizeEvent(QResizeEvent *event);
    void showEvent(QShowEvent *event);

private:
    Plasma::Applet *m_applet;
    Plasma::Containment *m_containment;
    Plasma::Corona *m_corona;
    Plasma::Direction m_direction;
    int m_rotation;
};

#endif // multiple inclusion guard
