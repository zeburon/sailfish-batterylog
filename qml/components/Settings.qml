import QtQuick 2.0
import QtQuick.LocalStorage 2.0

import "../storage.js" as Storage
import "../globals.js" as Globals

QtObject
{
    property int energyLogDayCount: Globals.DEFAULT_ENERGY_LOG_DAY_COUNT;                         property string energyLogDayCountKey: "energyLogDayCount"
    property color lineColorChargingActive: Globals.DEFAULT_LINE_COLOR_CHARGING_ACTIVE;           property string lineColorChargingActiveKey: "lineColorChargingActive"
    property color lineColorChargingInactive: Globals.DEFAULT_LINE_COLOR_CHARGING_INACTIVE;       property string lineColorChargingInactiveKey: "lineColorChargingInactive"
    property color lineColorDischargingActive: Globals.DEFAULT_LINE_COLOR_DISCHARGING_ACTIVE;     property string lineColorDischargingActiveKey: "lineColorDischargingActive"
    property color lineColorDischargingInactive: Globals.DEFAULT_LINE_COLOR_DISCHARGING_INACTIVE; property string lineColorDischargingInactiveKey: "lineColorDischargingInactive"

    // -----------------------------------------------------------------------

    function loadValues()
    {
        Storage.startInit();

        // load energyLogDayCount
        var storedEnergyLogDayCount = Storage.getValue(energyLogDayCountKey);
        if (storedEnergyLogDayCount)
            energyLogDayCount = storedEnergyLogDayCount;

        // load lineColorChargingActive
        var storedLineColorChargingActive = Storage.getValue(lineColorChargingActiveKey);
        if (storedLineColorChargingActive)
            lineColorChargingActive = storedLineColorChargingActive;

        // load lineColorChargingInactive
        var storedLineColorChargingInactive = Storage.getValue(lineColorChargingInactiveKey);
        if (storedLineColorChargingInactive)
            lineColorChargingInactive = storedLineColorChargingInactive;

        // load lineColorDischargingActive
        var storedLineColorDischargingActive = Storage.getValue(lineColorDischargingActiveKey);
        if (storedLineColorDischargingActive)
            lineColorDischargingActive = storedLineColorDischargingActive;

        // load lineColorChargingInactive
        var storedLineColorDischargingInactive = Storage.getValue(lineColorDischargingInactiveKey);
        if (storedLineColorDischargingInactive)
            lineColorDischargingInactive = storedLineColorDischargingInactive;

    }

    // -----------------------------------------------------------------------

    function startStoringValueChanges()
    {
        Storage.finishInit();
    }

    // -----------------------------------------------------------------------

    onEnergyLogDayCountChanged:
    {
        Storage.setValue(energyLogDayCountKey, energyLogDayCount);
    }
    onLineColorChargingActiveChanged:
    {
        Storage.setValue(lineColorChargingActiveKey, lineColorChargingActive);
    }
    onLineColorChargingInactiveChanged:
    {
        Storage.setValue(lineColorChargingInactiveKey, lineColorChargingInactive);
    }
    onLineColorDischargingActiveChanged:
    {
        Storage.setValue(lineColorDischargingActiveKey, lineColorDischargingActive);
    }
    onLineColorDischargingInactiveChanged:
    {
        Storage.setValue(lineColorDischargingInactiveKey, lineColorDischargingInactive);
    }
}
