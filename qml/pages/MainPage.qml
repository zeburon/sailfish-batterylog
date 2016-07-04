import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../globals.js" as Globals

Page
{
    id: page

    // -----------------------------------------------------------------------

    property bool pageActive: status === PageStatus.Active

    // -----------------------------------------------------------------------

    function refreshDrawings()
    {
        refreshBattery();
        refreshGraph();
    }

    function refreshBattery()
    {
        if (pageActive)
        {
            battery.refresh();
        }
    }

    function refreshGraph()
    {
        if (pageActive)
        {
            graph.refresh();
        }
    }

    // -----------------------------------------------------------------------

    allowedOrientations: Orientation.Portrait
    onPageActiveChanged:
    {
        if (pageActive)
        {
            refreshDrawings();
            pageStack.pushAttached(eventPage);
        }
    }

    // -----------------------------------------------------------------------

    SilicaFlickable
    {
        anchors { fill: parent; leftMargin: Theme.paddingSmall; rightMargin: Theme.paddingSmall }
        contentHeight: column.height

        PullDownMenu
        {
            MenuItem
            {
                text: qsTr("About Battery Log")
                onClicked:
                {
                    pageStack.push(aboutPage);
                }
            }
            MenuItem
            {
                text: qsTr("Settings")
                onClicked:
                {
                    pageStack.push(settingsPage);
                }
            }
        }
        Column
        {
            id: column

            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader
            {
                title: qsTr("Battery Log")
            }
            Row
            {
                width: parent.width
                height: 130

                Column
                {
                    width: 150
                    height: parent.height

                    Label
                    {
                        width: parent.width
                        height: parent.height * 0.6
                        text: batteryInfo.capacity + "%"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignBottom
                        color: Theme.highlightColor
                        font { family: "Monospace"; pixelSize: parent.width * 0.35 }
                    }
                    Label
                    {
                        width: parent.width
                        height: parent.height * 0.4
                        text: batteryInfo.status
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignTop
                        color: Theme.highlightColor
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
                    }
                }
                Battery
                {
                    id: battery

                    width: parent.width - 150
                    height: parent.height
                    capacity: batteryInfo.capacity
                    charging: logs.charging
                }
            }

            Item
            {
                width: 1
                height: Theme.paddingLarge
            }

            Label
            {
                id: remainingTimeLabel

                width: parent.width
                text:
                {
                    if (logs.full)
                        return qsTr("fully charged");
                    else if (logs.charging)
                    {
                        if (logs.remainingMinutesTrend > 0)
                            return logs.remainingTimeTrendLong;
                        else
                            return "";
                    }
                    else if (logs.averagePowerPrognosis > 0)
                        return logs.remainingTimePrognosisLong;
                    else if (logs.remainingMinutesTrend > 0)
                        return logs.remainingTimeTrendLong;
                    else
                        return "";
                }
                color: Theme.primaryColor
                horizontalAlignment: Text.AlignHCenter
                font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
            }
            Label
            {
                id: remainingTimeDescriptionLabel

                width: parent.width
                text:
                {
                    if (logs.full)
                        return "";

                    if (logs.remainingMinutesTrend > 0)
                    {
                        if (logs.charging)
                            return qsTr("until full");
                        else
                            return qsTr("until empty");
                    }
                    return qsTr("calculating...");
                }
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
            }

            Label
            {
                width: parent.width
                text:
                {
                    if (logs.averagePowerPrognosis > 0)
                    {
                        if (logs.charging)
                            return logs.remainingTimePrognosisLong;
                        else
                            return logs.remainingTimeFullPrognosisLong;
                    }
                    else
                        return "";
                }
                color: Theme.primaryColor
                horizontalAlignment: Text.AlignHCenter
                font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
            }
            Label
            {
                width: parent.width
                text:
                {
                    if (logs.averagePowerPrognosis > 0)
                    {
                        if (logs.charging)
                            return qsTr("when unplugged now");
                        else
                            return qsTr("when fully charged");
                    }
                    else
                        return qsTr("more data required");
                }
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
            }

            Item
            {
                width: 1
                height: Theme.paddingLarge
            }

            Graph
            {
                id: graph

                width: parent.width
                height: 150
                dayCount: settings.largeGraphDayCount

                MouseArea
                {
                    anchors { fill: parent; leftMargin: moveForwardsButton.width + 4; rightMargin: moveBackwardsButton.width + 4 }
                    onClicked:
                    {
                        var idx = Globals.LARGE_GRAPH_DAY_COUNTS.indexOf(settings.largeGraphDayCount);
                        var newDayCount = Globals.LARGE_GRAPH_DAY_COUNTS[(idx + 1) % Globals.LARGE_GRAPH_DAY_COUNTS.length];
                        if (newDayCount > settings.energyLogDayCount)
                            newDayCount = Globals.LARGE_GRAPH_DAY_COUNTS[0];

                        settings.largeGraphDayCount = newDayCount;
                        graph.refresh();

                        // update info label
                        graphInfoLabel.text = qsTr("Displaying %1 day(s)").arg(newDayCount);
                        graphInfoTimer.restart();
                    }
                }

                IconButton
                {
                    id: moveForwardsButton

                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    icon.source: "image://theme/icon-l-right"
                    visible: graph.dayOffset > 0
                    onClicked:
                    {
                        --graph.dayOffset;
                        graph.refresh();

                        // update info label
                        if (graph.dayOffset === 0)
                            graphInfoLabel.text = qsTr("Starting now");
                        else
                            graphInfoLabel.text = qsTr("Starting %1 day(s) ago").arg(graph.dayOffset);

                        graphInfoTimer.restart();
                    }
                }

                IconButton
                {
                    id: moveBackwardsButton

                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    icon.source: "image://theme/icon-l-left"
                    visible: !graph.reachedStart
                    onClicked:
                    {
                        ++graph.dayOffset;
                        graph.refresh();

                        // update info label
                        graphInfoLabel.text = qsTr("Starting %1 day(s) ago").arg(graph.dayOffset);
                        graphInfoTimer.restart();
                    }
                }

                Label
                {
                    id: graphInfoLabel

                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.top }
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeTiny }
                    opacity: graphInfoTimer.running ? 1 : 0

                    Behavior on opacity
                    {
                        NumberAnimation { easing.type: Easing.InOutQuart; duration: 200 }
                    }
                }
                Timer
                {
                    id: graphInfoTimer

                    repeat: false
                    interval: 2000
                }
            }
            Row
            {
                id: graphLegendRow

                width: parent.width
                height: 10
                opacity: 0.75

                Item
                {
                    id: graphLegendDischarging

                    width: parent.width / 2
                    height: parent.height

                    GraphLegendItemRight
                    {
                        anchors { left: parent.left; right: dischargingLabel.left; verticalCenter: parent.verticalCenter}
                        height: parent.height
                        itemColor: graph.lineColorDischargingActive
                        itemLabel: qsTr("on")
                    }
                    GraphLegendCategory
                    {
                        id: dischargingLabel

                        anchors { centerIn: parent }
                        height: parent.height
                        categoryLabel: qsTr("discharging")
                    }
                    GraphLegendItemLeft
                    {
                        anchors { left: dischargingLabel.right; right: parent.right; verticalCenter: parent.verticalCenter}
                        height: parent.height
                        itemColor: graph.lineColorDischargingInactive
                        itemLabel: qsTr("standby")
                    }
                }
                Item
                {
                    id: graphLegendCharging

                    width: parent.width / 2
                    height: parent.height

                    GraphLegendItemRight
                    {
                        anchors { left: parent.left; right: chargingLabel.left; verticalCenter: parent.verticalCenter}
                        height: parent.height
                        itemColor: graph.lineColorChargingActive
                        itemLabel: qsTr("on")
                    }
                    GraphLegendCategory
                    {
                        id: chargingLabel

                        anchors { centerIn: parent }
                        height: parent.height
                        categoryLabel: qsTr("charging")
                    }
                    GraphLegendItemLeft
                    {
                        anchors { left: chargingLabel.right; right: parent.right; verticalCenter: parent.verticalCenter}
                        height: parent.height
                        itemColor: graph.lineColorChargingInactive
                        itemLabel: qsTr("standby")
                    }
                }
            }

            Item
            {
                width: 1
                height: Theme.paddingLarge
            }

            Row
            {
                width: parent.width

                Label
                {
                    width: parent.width / 2
                    text: qsTr("Current")
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                }
                Label
                {
                    width: parent.width / 2
                    text: qsTr("Voltage")
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                }
            }
            Row
            {
                width: parent.width

                Label
                {
                    width: parent.width / 2
                    text: batteryInfo.current + " mA"
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                }
                Label
                {
                    width: parent.width / 2
                    text: batteryInfo.voltage + " mV"
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                }
            }

            Item
            {
                width: 1
                height: Theme.paddingMedium
            }

            Row
            {
                width: parent.width

                Label
                {
                    width: parent.width / 2
                    text: qsTr("Energy")
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                }
                Label
                {
                    width: parent.width / 2
                    text: qsTr("Health")
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                }
            }
            Row
            {
                width: parent.width

                Label
                {
                    width: parent.width / 2
                    text: batteryInfo.energy + " mWh"
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                }
                Label
                {
                    width: parent.width / 2
                    text: batteryInfo.health
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
                }
            }
        }
    }
}
