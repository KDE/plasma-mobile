/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#include "settingsmodule.h"
#include "settingsmodule_macros.h"

class SettingsModulePrivate {

public:
    SettingsModulePrivate(SettingsModule *q):
                  q(q),
                  m_settings(0){}

    SettingsModule *q;
    QObject *m_settings;
};

SettingsModule::SettingsModule(QObject *parent) : QObject(parent),
                                  d(new SettingsModulePrivate(this))
{}

SettingsModule::~SettingsModule()
{
    delete d;
}

QObject* SettingsModule::settingsObject()
{
    return d->m_settings;
}

void SettingsModule::setSettingsObject(QObject *settings)
{
    d->m_settings = settings;
}