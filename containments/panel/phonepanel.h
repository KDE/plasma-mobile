/***************************************************************************
 *   Copyright (C) 2015 Marco Martin <mart@kde.org>                        *
 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#ifndef PHONEPANEL_H
#define PHONEPANEL_H


#include <Plasma/Containment>

#include <gst/gst.h>


class PhonePanel : public Plasma::Containment
{
    Q_OBJECT

public:
    PhonePanel( QObject *parent, const QVariantList &args );
    ~PhonePanel();

public Q_SLOTS:
    void executeCommand(const QString &command);
    void toggleTorch();

private:
    GstElement* m_pipeline;
    GstElement* m_sink;
    GstElement* m_source;
    bool m_running = false;
};

#endif
