// SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.19 as Kirigami

Item {
    id: root

    // intended to be used in delays, makes the next step run immediately (as long as duration isn't longer than this value)
    readonly property int immediate: -1000000

    // list of animations to play
    required property list<Animation> animations

    // time delay between animation steps (in ms), if negative it will start the next animation that many ms before the end of the current
    required property list<int> delays
    required property int endTimeout

    property int _step: 0
    property bool _startedStep: false

    property bool running: false
    property bool hasFinished: false
    signal finished()

    function start(): void {
        if (animations.length != (delays.length + 1)) {
            console.error("[Gesture Tutorial] Animation and delay list lengths don't match! Delays should be one shorter.");
            return;
        }
        if (running) {
            for (let i = 0; i < animations.length; i++) {
                animations[i].stop();
            }
            stepTimer.stop();
            loopTimer.stop();
        }
        _step = 0;
        _startedStep = false;
        hasFinished = false;
        running = true;
        body();
    }

    function stop(): void {
        if (!running) {
            return;
        }
        loopTimer.stop();
        stepTimer.stop();
        animations[_step].stop();
    }

    function body(): void {
        if (_step >= animations.length) {
            hasFinished = true;
            finished();
            return;
        }

        //console.warn("step timer", stepTimer.running)
        let currentAnim = animations[_step];
        if (!currentAnim.running && _startedStep == false) {
            _startedStep = true;
            currentAnim.start();
            if (_step < delays.length && delays[_step] < 0) {
                stepTimer.interval = Math.max(0, currentAnim.duration + delays[_step]);
                stepTimer.start();
            }
            else {
                loopTimer.interval = currentAnim.duration;
                loopTimer.start();
            }
        }
        else if (!currentAnim.running && !stepTimer.running) {
            if (_step < delays.length) {
                stepTimer.interval = delays[_step];
            }
            else {
                stepTimer.interval = endTimeout;
            }
            stepTimer.start()
        }
        else {
            //console.warn("looping")
            loopTimer.start();
        }
    }

    Timer {
        id: loopTimer
        interval: 100

        onTriggered: {
            root.body();
        }
    }

    Timer {
        id: stepTimer

        onTriggered: {
            root._startedStep = false;
            root._step++;
            root.body();
        }
    }
}
