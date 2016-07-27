import QtQuick 2.0
import Sailfish.Silica 1.0

import "../timeformat.js" as TimeFormat

Item
{
    // event information
    property date time
    property int energy
    property bool charging
    property string event

    // information of next event
    property date endTime
    property int endEnergy
    property string endEvent

    property int startCapacity: batteryInfo.valid ? Math.max(0, Math.min(100, Math.round(100.0 * energy / batteryInfo.energyFull))) : 0
    property int endCapacity: batteryInfo.valid ? Math.max(0, Math.min(100, Math.round(100.0 * endEnergy / batteryInfo.energyFull))) : 0
    property int capacityChange: batteryInfo.valid ? Math.max(0, Math.min(100, Math.abs(isCurrentEvent ? batteryInfo.capacity - startCapacity : startCapacity - endCapacity))) : 0

    property string formattedEventString:
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


    property int durationInMinutes: Math.floor((endTime - time) / 60000)
    property string durationString: durationInMinutes > 0 ? TimeFormat.getLongTimeString(durationInMinutes) : "-"

    property bool isStartEvent: event === "Start"
    property bool isFullEvent: event === "Full"
    property bool isCurrentEvent: endEnergy === 0

    readonly property int capacityWidth: parent.width / 6
    readonly property int rowHeight: Theme.fontSizeExtraLarge * 1.25
    readonly property int separatorHeight: rowHeight / 4

    // -----------------------------------------------------------------------

    function updateCurrentEventDuration()
    {
        if (isCurrentEvent)
        {
            endTime = new Date(Date.now());
        }
    }

    // -----------------------------------------------------------------------

    width: parent.width
    height: isStartEvent ? separatorHeight : rowHeight

    // -----------------------------------------------------------------------

    Rectangle
    {
        id: startGradient

        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        height: separatorHeight
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

        anchors { left: parent.left; leftMargin: Theme.paddingMedium; right: parent.right; rightMargin: Theme.paddingMedium }
        height: parent.height
        visible: !isStartEvent

        Label
        {
            id: capacityChangeLabel

            anchors { left: parent.left; top: parent.top }
            visible: !isFullEvent
            width: capacityWidth
            text: (capacityChange !== 0 ? (charging ? "+" : "-") : "") + capacityChange + "%"
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: charging ? "green" : "red"
            font { family: "Monospace"; pixelSize: Theme.fontSizeMedium }
        }
        Label
        {
            id: eventLabel

            anchors { left: capacityChangeLabel.right; leftMargin: 5; verticalCenter: capacityChangeLabel.verticalCenter }
            text: formattedEventString
            color: isCurrentEvent ? Theme.highlightColor : Theme.primaryColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium; italic: isFullEvent }
        }
        Label
        {
            id: timeDurationLabel

            anchors { right: parent.right; verticalCenter: capacityChangeLabel.verticalCenter }
            text: durationString
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
            text: startCapacity + "%"
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
            opacity: 0.6
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Theme.secondaryColor
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeTiny }
        }
    }
}
