import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../globals.js" as Globals

Page
{
    id: page

    // -----------------------------------------------------------------------

    property bool pageActive: status === PageStatus.Active
    property int currentEventCurrent
    property real currentDayCount

    // -----------------------------------------------------------------------

    signal lineColorsModified()

    // -----------------------------------------------------------------------

    function init()
    {
        loadEnergyLogDayCount();
    }

    function loadEnergyLogDayCount()
    {
        var energyLogDayCountIdx = Globals.ENERGY_LOG_DAY_COUNTS.indexOf(settings.energyLogDayCount);
        energyLogDayCountComboBox.currentIndex = energyLogDayCountIdx;
    }

    function saveEnergyLogDayCount(newDayCount)
    {
        settings.energyLogDayCount = newDayCount;
        logs.cleanupEnergyEntries();
        updateEnergyLogStats();
    }

    function clearEnergyLog()
    {
        logs.clearEnergyEntries();
        updateEnergyLogStats();
    }

    function updateEnergyLogStats()
    {
        currentEventCurrent = logs.getCurrentEnergyEventCount();
        currentDayCount = logs.getCurrentEnergyDayCount();
    }

    // -----------------------------------------------------------------------

    onPageActiveChanged:
    {
        if (pageActive)
        {
            updateEnergyLogStats();
        }
    }

    // -----------------------------------------------------------------------

    Column
    {
        id: column

        width: page.width
        spacing: 0

        PageHeader
        {
            title: qsTr("Settings")
        }

        // energy log day count
        BackgroundItem
        {
            ComboBox
            {
                id: energyLogDayCountComboBox

                label: qsTr("Storage period")
                menu: ContextMenu
                {
                    Repeater
                    {
                        model: Globals.ENERGY_LOG_DAY_COUNTS.length

                        MenuItem
                        {
                            text: Globals.ENERGY_LOG_DAY_COUNTS[index] + qsTr(" days")
                            onClicked:
                            {
                                var newDayCount = Globals.ENERGY_LOG_DAY_COUNTS[index];
                                if (newDayCount >= currentDayCount)
                                    saveEnergyLogDayCount(newDayCount);
                                else
                                    energyLogDayCountRemorseItem.execute(energyLogDayCountComboBox, qsTr("Deleting %1 days").arg((currentDayCount - newDayCount).toFixed(1)), function() { saveEnergyLogDayCount(newDayCount); });
                            }
                        }
                    }
                }
                RemorseItem
                {
                    id: energyLogDayCountRemorseItem

                    onCanceled:
                    {
                        loadEnergyLogDayCount();
                    }
                }
            }
        }
        Label
        {
            id: energyLogInfoLabel

            x: Theme.paddingLarge
            height: Theme.itemSizeExtraSmall
            color: Theme.secondaryColor
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
            text: qsTr("%1 events of %2 days stored").arg(currentEventCurrent).arg(currentDayCount.toFixed(1))
        }

        BackgroundItem
        {
            Button
            {
                id: energyLogClearButton

                anchors { horizontalCenter: parent.horizontalCenter }
                text: qsTr("Clear logs")
                width: Theme.buttonWidthLarge
                onClicked:
                {
                    energyLogClearRemorseItem.execute(energyLogClearButton, qsTr("Clearing logs"), function() { clearEnergyLog(); });
                }

                RemorseItem
                {
                    id: energyLogClearRemorseItem
                }
            }
        }

        SectionHeader
        {
            text: qsTr("Line Colors")
        }

        ColorChooserItem
        {
            id: lineColorChargingActiveChooser

            colorValue: settings.lineColorChargingActive
            colorLabel: qsTr("Charging + on")
            onColorValueChanged:
            {
                settings.lineColorChargingActive = colorValue;
                lineColorsModified();
            }
        }
        ColorChooserItem
        {
            id: lineColorChargingInactiveChooser

            colorValue: settings.lineColorChargingInactive
            colorLabel: qsTr("Charging + standby")
            onColorValueChanged:
            {
                settings.lineColorChargingInactive = colorValue;
                lineColorsModified();
            }
        }
        ColorChooserItem
        {
            id: lineColorDischargingActiveChooser

            colorValue: settings.lineColorDischargingActive
            colorLabel: qsTr("Discharging + on")
            onColorValueChanged:
            {
                settings.lineColorDischargingActive = colorValue;
                lineColorsModified();
            }
        }
        ColorChooserItem
        {
            id: lineColorDischargingInactiveChooser

            colorValue: settings.lineColorDischargingInactive
            colorLabel: qsTr("Discharging + standby")
            onColorValueChanged:
            {
                settings.lineColorDischargingInactive = colorValue;
                lineColorsModified();
            }
        }
        Item
        {
            width: 1
            height: Theme.paddingLarge
        }
        Button
        {
            anchors { horizontalCenter: parent.horizontalCenter }
            text: qsTr("Reset Colors")
            width: Theme.buttonWidthLarge
            onClicked:
            {
                lineColorChargingActiveChooser.colorValue      = Globals.DEFAULT_LINE_COLOR_CHARGING_ACTIVE;
                lineColorChargingInactiveChooser.colorValue    = Globals.DEFAULT_LINE_COLOR_CHARGING_INACTIVE;
                lineColorDischargingActiveChooser.colorValue   = Globals.DEFAULT_LINE_COLOR_DISCHARGING_ACTIVE;
                lineColorDischargingInactiveChooser.colorValue = Globals.DEFAULT_LINE_COLOR_DISCHARGING_INACTIVE;
                lineColorsModified();
            }
        }
    }
}
