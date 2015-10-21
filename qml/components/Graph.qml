import QtQuick 2.0

import "../globals.js" as Globals

Item
{

    property int dayCount: 1
    property int dayOffset: 0
    property bool showDividers: true
    property bool showDividerLabels: true
    property bool reachedStart
    property real backgroundOpacity: 0.45
    property int lineWidth: 4
    property int energyFullValue: batteryInfo.energyFullDesign

    property int endSize: 8
    property int endX
    property int endY
    property string endColor

    property color lineColorChargingActive: settings.lineColorChargingActive
    property color lineColorChargingInactive: settings.lineColorChargingInactive
    property color lineColorDischargingActive: settings.lineColorDischargingActive
    property color lineColorDischargingInactive: settings.lineColorDischargingInactive

    // -----------------------------------------------------------------------

    function refresh()
    {
        canvas.requestPaint();
    }

    // -----------------------------------------------------------------------

    Rectangle
    {
        id: background

        anchors { fill: parent; margins: 1 }
        radius: 10
        border.width: 3
        border.color: "#99000000"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#aaddaa" }
            GradientStop { position: 0.2; color: "#aaaaaa" }
            GradientStop { position: 0.8; color: "#222222" }
            GradientStop { position: 1.0; color: "#662222" }
        }
        opacity: backgroundOpacity
    }

    Canvas
    {
        id: canvas

        property real xPerMilliSecond: (width - endSize / 2) / (dayCount * 24 * 3600 * 1000)
        property int yOffset: lineWidth / 2
        property int maximumHeight: height - yOffset * 2
        property int mergeSegmentDistance: 6

        function getLineColor(charging, active)
        {
            if (charging)
            {
                if (active)
                    return lineColorChargingActive;
                else
                    return lineColorChargingInactive;
            }
            else
            {
                if (active)
                    return lineColorDischargingActive;
                else
                    return lineColorDischargingInactive;
            }
        }

        function drawDividers(context, startTime)
        {
            context.globalAlpha = 0.3;
            context.beginPath();
            context.lineWidth = 3;
            for (var dividerIdx = 0; dividerIdx <= dayCount; ++dividerIdx)
            {
                var dividerTime = new Date(Date.now());
                dividerTime.setDate(dividerTime.getDate() - dayOffset - dividerIdx);
                dividerTime.setHours(0);
                dividerTime.setMinutes(0);
                dividerTime.setSeconds(0);

                var dividerX = (dividerTime - startTime) * xPerMilliSecond;
                context.moveTo(dividerX, 0);
                context.lineTo(dividerX, height);
            }
            context.strokeStyle = "black";
            context.stroke();
        }

        function drawDividerLabels(context, startTime)
        {
            context.globalAlpha = 0.3;
            context.font = "bold 12pt sans-serif";
            context.fillStyle = "white";
            for (var labelIdx = 0; labelIdx <= dayCount; ++labelIdx)
            {
                var labelTime = new Date(Date.now());
                labelTime.setDate(labelTime.getDate() - dayOffset - labelIdx);
                labelTime.setHours(0);
                labelTime.setMinutes(0);
                labelTime.setSeconds(0);

                var labelX = (labelTime - startTime) * xPerMilliSecond;
                context.fillText(Qt.formatDate(labelTime, "dd.MM"), labelX + 4, height);
            }
        }

        function drawEnd(context)
        {
            context.globalAlpha = 0.2;
            context.beginPath();

            var segmentCount = Math.round(height / endSize);
            segmentCount = segmentCount + segmentCount % 2 + 1;
            var increment = height / segmentCount;
            var xStart = width - endSize;
            var y      = 0;
            while (y < height)
            {
                context.rect(xStart, y, endSize, increment);
                y += increment * 2;
            }

            context.fillStyle = getLineColor(logs.charging, logs.active);
            context.fill();
        }

        anchors { fill: parent; margins: 7 }
        onPaint:
        {
            var entries = logs.getLatestEnergyEntries(dayCount, dayOffset);
            var startTime = new Date(Date.now());
            startTime.setDate(startTime.getDate() - dayOffset - dayCount);

            var context = getContext("2d");
            context.reset();
            endX = endY = -1;
            reachedStart = (dayOffset + dayOffset) > logs.getCurrentEnergyEventCount();

            // empty graph: no entries found
            if (entries.length < 1)
                return;

            // day dividers
            if (showDividers)
                drawDividers(context, startTime);

            // day labels
            if (showDividerLabels)
                drawDividerLabels(context, startTime);

            // highlight end of graph
            if (dayOffset === 0)
                drawEnd(context);

            // energy line
            context.globalAlpha = 1.0;
            context.beginPath();
            context.lineWidth = lineWidth;
            context.lineJoin = "round";
            context.lineCap = "round";
            context.translate(0, lineWidth / 2);

            var lastX, lastY, newX, newY, segmentCharging, segmentActive, segmentLength = 0, sessionLength = 0;
            for (var idx = entries.length - 1; idx >= 0; --idx)
            {
                var entry    = entries[idx];
                var time     = entry[0];
                var energy   = entry[1];
                var charging = entry[2];
                var active   = entry[3];
                var event    = entry[4];

                // calculate coordinates of entry
                newX = Math.round((time - startTime) * xPerMilliSecond);
                newY = Math.round(Math.max(0.0, maximumHeight * (1.0 - energy / energyFullValue)));

                // start of a new session
                if (sessionLength === 0)
                {
                    context.moveTo(newX + 1, newY);
                    segmentCharging = charging;
                    segmentActive = active;
                    segmentLength = 0;

                    // this is the latest entry - we use this information to draw the endHighlight item
                    if (dayOffset === 0 && idx === entries.length - 1)
                    {
                        endX = newX;
                        endY = newY + yOffset;
                        endColor = getLineColor(segmentCharging, segmentActive);
                    }
                }
                // end of current session (when the application was started)
                else if (event === "Start")
                {
                    context.lineTo(newX, newY);
                    context.strokeStyle = getLineColor(segmentCharging, segmentActive);
                    context.stroke();
                    sessionLength = 0;
                    continue;
                }
                // end of current segment - start with a new one (=> switch color)
                else if (charging !== segmentCharging || active !== segmentActive)
                {
                    // finish old segment: only visible if length is longer than 1 pixel
                    if (segmentLength === 0)
                    {
                        var singleX = newX, singleY = newY;
                        if (singleX === lastX && singleY === lastY)
                        {
                            singleY = lastY + 1;
                        }
                        context.lineTo(singleX, singleY);
                    }
                    else
                    {
                        context.lineTo(newX, newY);
                    }
                    context.strokeStyle = getLineColor(segmentCharging, segmentActive);
                    context.stroke();

                    // start new segment
                    context.beginPath();
                    context.moveTo(newX, newY);
                    segmentCharging = charging;
                    segmentActive = active;
                    segmentLength = 0;
                }
                // continue with segment
                else if (Math.abs(newX - lastX) > mergeSegmentDistance || Math.abs(newY - lastY) > mergeSegmentDistance)
                {
                    context.lineTo(newX, newY);
                    ++segmentLength;
                }
                // nobody seems to be interested in this entry :)
                else
                {
                    continue;
                }

                ++sessionLength;
                lastX = newX;
                lastY = newY;
            }
            context.strokeStyle = getLineColor(segmentCharging, segmentActive);
            context.stroke();
        }

        Rectangle
        {
            id: endHighlight

            visible: endX > 0
            anchors { horizontalCenter: parent.left; horizontalCenterOffset: endX; verticalCenter: parent.top; verticalCenterOffset: endY }
            color: endColor
            width: endSize
            height: endSize
            radius: width / 2
        }
    }
}
