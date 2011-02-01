/*
 *   Copyright (C) 2010 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
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

#include "nepomukmobileengine.h"
#include "testsource.h"

#include <KDebug>


NepomukMobileTest::NepomukMobileTest(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent, args)
{
    setMinimumPollingInterval(2 * 1000); // 2 seconds minimum
}

NepomukMobileTest::~NepomukMobileTest()
{
}

bool NepomukMobileTest::sourceRequestEvent(const QString &name)
{
    if (!name.startsWith("test") ) {
        return false;
    }

    updateSourceEvent(name); //start a download
    return true;
}


bool NepomukMobileTest::updateSourceEvent(const QString &name)
{
    kDebug() << name;


    TestSource *source = dynamic_cast<TestSource*>(containerForSource(name));

    if (!source) {
        source = new TestSource(this);
        source->setObjectName(name);

        addSource(source);
    }


    source->update();
    return false;
}

#include "nepomukmobileengine.moc"
