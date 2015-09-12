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
                    if (logs.charging)
                        return logs.remainingTimeTrendLong;
                    else if (logs.averagePowerPrognosis > 0)
                        return logs.remainingTimePrognosisLong;
                    else
                        return logs.remainingTimeTrendLong;
                }
                color: Theme.primaryColor
                horizontalAlignment: Text.AlignHCenter
                font { family: Theme.fontFamily; pixelSize: Theme.fontSizeLarge }
            }
            Label
            {
                id: remainingTimeDescriptionLabel

                width: parent.width
                text: logs.charging ? qsTr("until full") : qsTr("until empty")
                visible: remainingTimeLabel.text !== ""
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
                        else return qsTr("when fully charged");
                    }
                    else
                        return qsTr("still collecting data");
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
                dayCount: Globals.LARGE_GRAPH_DAY_COUNT

                IconButton
                {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    icon.source: "image://theme/icon-l-right"
                    visible: graph.dayOffset > 0
                    onClicked:
                    {
                        --graph.dayOffset;
                        graph.refresh();
                    }
                }

                IconButton
                {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    icon.source: "image://theme/icon-l-left"
                    visible: !graph.reachedStart
                    onClicked:
                    {
                        ++graph.dayOffset;
                        graph.refresh();
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
