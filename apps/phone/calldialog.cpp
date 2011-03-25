/***************************************************************************
 *   Copyright 2011 by Davide Bettio <davide.bettio@kdemail.net>           *
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

#include "calldialog.h"

#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <QDeclarativeItem>
#include <kdeclarative.h>

#include <ofono-qt/ofonovoicecall.h>
#include <kdebug.h>
#include <klocalizedstring.h>

CallDialog::CallDialog(OfonoVoiceCall *voiceCall)
{
    m_voiceCall = voiceCall;
    connect(m_voiceCall, SIGNAL(stateChanged(const QString &)), this, SLOT(stateChanged(const QString &)));
    
    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    kdeclarative.setupBindings();
    
    rootContext()->setContextProperty("callState", m_voiceCall->state());
#ifdef FAKE_CONTACT
    rootContext()->setContextProperty("caller", "Foo Bar");
    rootContext()->setContextProperty("callerDettails",  i18nc("is calling you from %1 (%2)", "is calling you from home (001235)").arg("home", m_voiceCall->lineIdentification()));
#else
    rootContext()->setContextProperty("caller", m_voiceCall->lineIdentification());
#endif
    rootContext()->setContextProperty("phoneNumberType", "home");
    rootContext()->setContextProperty("phoneNumber", m_voiceCall->lineIdentification());
    setSource(QUrl::fromLocalFile("CallDialog.qml"));
    connect(rootObject(), SIGNAL(hangup()), this, SLOT(hangup()));
    connect(rootObject(), SIGNAL(answer()), this, SLOT(answer()));
}

CallDialog::~CallDialog()
{
}

void CallDialog::hangup()
{
    m_voiceCall->hangup();
    hide();
}

void CallDialog::answer()
{
    m_voiceCall->answer();
}

void CallDialog::stateChanged(const QString &state)
{
    kDebug() << state;
    rootContext()->setContextProperty("callState", state);
}

#include "calldialog.moc"
