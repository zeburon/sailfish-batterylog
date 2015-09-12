import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../globals.js" as Globals

CoverBackground
{
    id: cover

    // -----------------------------------------------------------------------

    property bool coverActive: status === Cover.Active
    property bool showOverview: true

    // -----------------------------------------------------------------------

    function refreshDrawings()
    {
        if (coverActive)
        {
            if (showOverview)
                battery.refresh();
            else
                graph.refresh();

            refreshDrawingsTimer.start();
        }
    }

    // -----------------------------------------------------------------------

    onCoverActiveChanged:
    {
        if (coverActive)
        {
            refreshDrawings();
        }
        else
        {
            refreshDrawingsTimer.stop();
        }
    }

    // -----------------------------------------------------------------------

    Column
    {
        id: overviewColumn

        anchors { fill: parent; margins: Theme.paddingMedium }
        visible: showOverview

        Label
        {
            width: parent.width
            text: batteryInfo.capacity + "%"
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryHighlightColor
            font { family: "Monospace"; pixelSize: Theme.fontSizeExtraLarge }
        }
        Battery
        {
            id: battery

            width: parent.width
            height: 50
            capacity: batteryInfo.capacity
            charging: logs.charging
        }
        Label
        {
            width: parent.width
            text: batteryInfo.status
            color: Theme.secondaryHighlightColor
            horizontalAlignment: Text.AlignHCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
        }
        Item
        {
            width: parent.width
            height: Theme.paddingSmall
        }
        Label
        {
            width: parent.width
            text: "Time left"
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignHCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
        }
        Label
        {
            width: parent.width
            text: logs.charging ? logs.remainingTimeTrendShort : logs.remainingTimePrognosisShort
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
        }
    }

    Column
    {
        id: powerColumn

        anchors { fill: parent; margins: Theme.paddingMedium }
        visible: !showOverview

        Graph
        {
            id: graph

            width: parent.width
            height: 75
            dayCount: Globals.SMALL_GRAPH_DAY_COUNT
            currentHighlightSize: 6
            showDividerLabels: false
        }
        Label
        {
            width: parent.width
            text: "Remaining"
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignHCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
        }
        Label
        {
            width: parent.width
            text: batteryInfo.energy + " mWh"
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
        }
        Label
        {
            width: parent.width
            text: "Average"
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignHCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
        }
        Label
        {
            width: parent.width
            text: (logs.averagePowerPrognosis > 0 ? logs.averagePowerPrognosis : "?") + " mW"
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
        }
    }

    Timer
    {
        id: refreshDrawingsTimer

        interval: 30000
        repeat: false
        onTriggered:
        {
            refreshDrawings();
        }
    }

    CoverActionList
    {
        id: coverAction

        CoverAction
        {
            id: coverSwitch

            iconSource: showOverview ? "image://theme/icon-cover-next" : "image://theme/icon-cover-previous"
            onTriggered:
            {
                showOverview = !showOverview;
                refreshDrawings();
            }
        }
    }
}
