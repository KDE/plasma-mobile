/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "candidateinactivitytimer_p.h"

CandidateInactivityTimer::CandidateInactivityTimer(int touchId, QQuickItem *candidate, AbstractTimer *timer, QObject *parent)
    : QObject(parent)
    , m_timer(timer)
    , m_touchId(touchId)
    , m_candidate(candidate)
{
    connect(m_timer, &AbstractTimer::timeout, this, &CandidateInactivityTimer::onTimeout);
    m_timer->setInterval(durationMs);
    m_timer->setSingleShot(true);
    m_timer->start();
}

CandidateInactivityTimer::~CandidateInactivityTimer()
{
    delete m_timer;
}

void CandidateInactivityTimer::onTimeout()
{
    qWarning("[TouchRegistry] Candidate for touch %d defaulted!", m_touchId);
    Q_EMIT candidateDefaulted(m_touchId, m_candidate);
}
