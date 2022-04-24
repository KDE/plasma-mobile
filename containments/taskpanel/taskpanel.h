/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef TASKPANEL_H
#define TASKPANEL_H

#include <Plasma/Containment>
#include <QWindow>

class OutputsModel;
class QAbstractItemModel;

namespace KWayland
{
namespace Client
{
class Output;
class PlasmaWindowManagement;
class PlasmaWindow;
class PlasmaShell;
class PlasmaShellSurface;
class Surface;
}
}

class TaskPanel : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(QWindow *panel READ panel WRITE setPanel NOTIFY panelChanged)

public:
    TaskPanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args);

    QWindow *panel();
    void setPanel(QWindow *panel);

    Q_INVOKABLE void setPanelHeight(qreal height);

    QAbstractItemModel *outputs() const;

Q_SIGNALS:
    void panelChanged();
    void locationChanged();

private:
    void initWayland();
    void updatePanelVisibility();
    QWindow *m_panel = nullptr;
    KWayland::Client::PlasmaShellSurface *m_shellSurface = nullptr;
    KWayland::Client::Surface *m_surface = nullptr;
    KWayland::Client::PlasmaShell *m_shellInterface = nullptr;
};

#endif
