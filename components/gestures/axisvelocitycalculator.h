/*
 *  SPDX-FileCopyrightText: 2013 Daniel d'Andrada <daniel.dandrada@canonical.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QElapsedTimer>
#include <QObject>
#include <QTime>

#include "timesource_p.h"

/*
  Estimates the current velocity of a finger based on recent movement along an axis

  Taking an estimate from a reasonable number of samples, instead of only
  from its last movement, removes wild variations in velocity caused
  by the jitter normally present in input from a touchscreen.

  Usage example:

    AxisVelocityCalculator {
        id: velocityCalculator
        trackedPosition: myMouseArea.mouseX
    }

    MouseArea {
        id: myMouseArea

        onReleased: {
            console.log("Drag velocity along the X axis before release was: "
                        + velocityCalculator.calculate())
        }
    }
 */

class AxisVelocityCalculator : public QObject
{
    Q_OBJECT

    /*
     * Position whose movement will be tracked to calculate its velocity
     */
    Q_PROPERTY(qreal trackedPosition READ trackedPosition WRITE setTrackedPosition NOTIFY trackedPositionChanged)

public:
    AxisVelocityCalculator(QObject *parent = nullptr);
    AxisVelocityCalculator(const SharedTimeSource &timeSource, QObject *parent = nullptr);

    qreal trackedPosition() const;
    void setTrackedPosition(qreal trackedPosition);

    Q_INVOKABLE qreal calculate();

    /**
     * Removes all stored movements from previous calls to setTrackedPosition()
     */
    Q_INVOKABLE void reset();

    /**
     * The minimum amount of samples needed for a velocity calculation.
     */
    static const int MIN_SAMPLES_NEEDED = 2;

    /**
     * Maximum number of movement samples stored.
     */
    static const int MAX_SAMPLES = 50;

    /**
     * Age of the oldest sample considered in the velocity calculations, in
     * milliseconds, compared to the most recent one.
     */
    static const int AGE_OLDEST_SAMPLE = 100;

Q_SIGNALS:
    void trackedPositionChanged(qreal value);

private:
    int numSamples() const;

    /**
     * Inform that trackedPosition remained motionless since the time it was
     * last changed.
     *
     * It's the same as calling setTrackedPosition(trackedPosition())
     */
    void updateIdleTime();

    /**
     * How much the finger has moved since processMovement() was last called.
     */
    void processMovement(qreal movement);

    class Sample
    {
    public:
        qreal mov; // movement distance since last sample
        qint64 time; // time, in milliseconds
    };

    Sample m_samples[MAX_SAMPLES]; // a circular buffer of samples
    int m_samplesRead; // index of the oldest sample available. -1 if buffer is empty
    int m_samplesWrite; // index where the next sample will be written

    SharedTimeSource m_timeSource;

    qreal m_trackedPosition;
};
