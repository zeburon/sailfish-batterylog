import QtQuick 2.0

import "../globals.js" as Globals

Item
{

    property int dayCount: 1
    property int dayOffset: 0
    property bool showDividers: true
    property bool showDividerLabels: true
    property bool reachedStart
    property int currentHighlightSize: 8
    property int currentX
    property int currentY
    property string currentColor
    property real backgroundOpacity: 0.45
    property int lineWidth: 4
    property int energyFullValue: batteryInfo.energyFull

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

        property real xPerMilliSecond: (width - currentHighlightSize) / (dayCount * 24 * 3600 * 1000)
        property int yOffset: lineWidth / 2
        property int energyLineHeight: height - yOffset * 2
        property int mergeLength: 6

        function getLineColor(charging, active)
        {
            if (charging)
            {
                if (active)
                    return "#ffc0ff00";
                else
                    return "#cc66a621";
            }
            else
            {
                if (active)
                    return "#ffbbbb00";
                else
                    return "#bbaaaaaa";
            }
        }

        function drawDividers(context, startTime)
        {
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

        anchors { fill: parent; margins: 7 }
        onPaint:
        {
            var entries = logs.getLatestEnergyEntries(dayCount, dayOffset);
            var context = getContext("2d");
            context.reset();

            if (entries.length < 1)
            {
                currentX = currentY = -1;
                return;
            }

            var startTime = new Date(Date.now());
            startTime.setDate(startTime.getDate() - dayOffset - dayCount);

            context.globalAlpha = 0.3;

            // day dividers
            if (showDividers)
                drawDividers(context, startTime);

            // day labels
            if (showDividerLabels)
                drawDividerLabels(context, startTime);

            // energy line
            context.globalAlpha = 1.0;
            context.beginPath();
            context.lineWidth = lineWidth;
            context.lineJoin = "round";
            context.lineCap = "round";
            context.translate(0, lineWidth / 2);

            var lastX, lastY, newX, newY, segmentLength, segmentCharging, segmentActive;
            for (var idx = entries.length - 1; idx >= 0; --idx)
            {
                var entry = entries[idx];
                var time     = entry[0];
                var energy   = entry[1];
                var charging = entry[2];
                var active   = entry[3];
                var event    = entry[4];

                // calculate coordinates of entry
                newX = Math.round((time - startTime) * xPerMilliSecond);
                newY = Math.round(energyLineHeight * (1.0 - energy / energyFullValue));

                // current entry
                if (idx === entries.length - 1)
                {
                    context.moveTo(newX, newY);
                    currentX = newX;
                    currentY = newY + yOffset;
                    segmentCharging = charging;
                    segmentActive = active;
                    currentColor = getLineColor(segmentCharging, segmentActive);
                }
                // new segment detected
                else if (event === "Start" || charging !== segmentCharging || active !== segmentActive)
                {
                    // finish old segment
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
                else if (idx === 0 || Math.abs(newX - lastX) > mergeLength || Math.abs(newY - lastY) > mergeLength)
                {
                    ++segmentLength;
                    context.lineTo(newX, newY);
                }
                else
                {
                    continue;
                }

                lastX = newX;
                lastY = newY;
            }

            context.strokeStyle = getLineColor(segmentCharging, segmentActive);
            context.stroke();
            reachedStart = lastX > 10;
        }

        Rectangle
        {
            id: currentHighlight

            visible: currentX > 0
            anchors { horizontalCenter: parent.left; horizontalCenterOffset: currentX; verticalCenter: parent.top; verticalCenterOffset: currentY }
            color: currentColor
            width: currentHighlightSize
            height: currentHighlightSize
            radius: width / 2
        }
    }
}
