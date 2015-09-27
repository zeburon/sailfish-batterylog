import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../globals.js" as Globals

Page
{
    id: page

    // -----------------------------------------------------------------------

    signal lineColorsModified()

    // -----------------------------------------------------------------------

    function init()
    {
        var energyLogDayCountIdx = Globals.ENERGY_LOG_DAY_COUNTS.indexOf(settings.energyLogDayCount);
        energyLogDayCountComboBox.currentIndex = energyLogDayCountIdx;
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
                            settings.energyLogDayCount = Globals.ENERGY_LOG_DAY_COUNTS[index];
                        }
                    }
                }
            }
        }

        SectionHeader
        {
            text: qsTr("Graph Colors")
        }

        ColorChooserItem
        {
            id: lineColorChargingActiveChooser

            colorValue: settings.lineColorChargingActive
            colorLabel: qsTr("Charging + Active")
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
            colorLabel: qsTr("Charging + Inactive")
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
            colorLabel: qsTr("Discharging + Active")
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
            colorLabel: qsTr("Discharging + Inactive")
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
            preferredWidth: Theme.buttonWidthLarge
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
