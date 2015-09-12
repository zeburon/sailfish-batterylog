import QtQuick 2.0
import Sailfish.Silica 1.0

import "../timeformat.js" as TimeFormat

Item
{
    property date time
    property int energy
    property bool charging
    property string event
    property string formattedEvent:
    {
        switch (event)
        {
            case "Charging": return qsTr("Charging");
            case "Discharging": return qsTr("Discharging");
            case "Full": return qsTr("Full");
            default: break;
        }
        return event;
    }
    property int capacity: Math.min(100.0, Math.round(100.0 * energy / batteryInfo.energyFull))

    property date nextTime
    property int nextEnergy
    property string nextEvent
    property int nextCapacity: Math.min(100.0, Math.round(100.0 * nextEnergy / batteryInfo.energyFull))
    property int capacityChange: Math.abs(isCurrentEvent ? batteryInfo.capacity - capacity : capacity - nextCapacity)
    property int timeDurationInMinutes: Math.floor((nextTime - time) / 60000)
    property string timeDurationString: TimeFormat.getLongTimeString(timeDurationInMinutes)

    property bool isStartEvent: event === "Start"
    property bool isFullEvent: event === "Full"
    property bool isCurrentEvent: nextEnergy === 0

    property int capacityWidth: 80

    // -----------------------------------------------------------------------

    function updateCurrentEventDuration()
    {
        if (isCurrentEvent)
        {
            nextTime = new Date(Date.now());
        }
    }

    // -----------------------------------------------------------------------

    width: parent.width
    height: isStartEvent ? 15 : 60

    // -----------------------------------------------------------------------

    Rectangle
    {
        id: startGradient

        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        height: 15
        visible: isStartEvent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00ffffff" }
            GradientStop { position: 0.5; color: "#33ffffff" }
            GradientStop { position: 1.0; color: "#00ffffff" }
        }
    }

    Item
    {
        id: eventInfo

        anchors { fill: parent }
        visible: !isStartEvent

        Label
        {
            id: capacityChangeLabel

            anchors { left: parent.left; top: parent.top }
            visible: !isFullEvent
            width: capacityWidth
            text: (charging ? "+" : "-") + capacityChange + "%"
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: charging ? "green" : "red"
            font { family: "Monospace"; pixelSize: Theme.fontSizeMedium }
        }
        Label
        {
            id: eventLabel

            anchors { left: capacityChangeLabel.right; leftMargin: 5; verticalCenter: capacityChangeLabel.verticalCenter }
            text: formattedEvent
            color: isCurrentEvent ? Theme.highlightColor : Theme.primaryColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium; italic: isFullEvent }
        }
        Label
        {
            id: timeDurationLabel

            anchors { right: parent.right; verticalCenter: capacityChangeLabel.verticalCenter }
            text: timeDurationString
            color: isCurrentEvent ? Theme.secondaryHighlightColor : Theme.secondaryColor
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeTiny }
        }

        Label
        {
            id: startCapacityLabel

            anchors { left: parent.left; bottom: parent.bottom }
            width: capacityWidth
            text: capacity + "%"
            opacity: 0.75
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Theme.secondaryColor
            font { family: "Monospace"; pixelSize: Theme.fontSizeTiny }
        }

        Label
        {
            id: timeLabel

            anchors { right: parent.right; verticalCenter: startCapacityLabel.verticalCenter }
            text: Qt.formatDateTime(time)
            opacity: 0.75
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Theme.secondaryColor
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeTiny }
        }
    }
}
