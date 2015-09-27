import QtQuick 2.0
import QtQuick.LocalStorage 2.0

import "../globals.js" as Globals
import "../energylog.js" as EnergyLog
import "../powerlog.js" as PowerLog
import "../timeformat.js" as TimeFormat

Item
{
    property real power: batteryInfo.current * batteryInfo.voltage / 1000 // [mW]
    property real energy: batteryInfo.energy // [mWh]
    property int capacity: batteryInfo.capacity // [0% - 100%]
    property bool charging: batteryInfo.status === "Full" || batteryInfo.status === "Charging"
    property bool full: batteryInfo.status === "Full"
    property string status: batteryInfo.status
    property bool active: screenInfo.on
    property bool initialized: false

    // trend: based on values gathered by PowerLog in the last minute
    property int averagePowerTrend
    property string remainingMinutesTrend
    property string remainingTimeTrendShort
    property string remainingTimeTrendLong

    // prognosis: based on values gathered by EnergyLog in the last 24 hours
    property int averagePowerPrognosis
    property string remainingMinutesPrognosis
    property string remainingTimePrognosisShort
    property string remainingTimePrognosisLong

    property string remainingMinutesFullPrognosis
    property string remainingTimeFullPrognosisShort
    property string remainingTimeFullPrognosisLong

    // -----------------------------------------------------------------------

    signal averagePowerUpdated()
    signal averageEnergyUpdated()
    signal energyEventAdded(var time, int energy, int charging, string event)
    signal capacityUpdated()

    // -----------------------------------------------------------------------

    function init()
    {
        PowerLog.init();
        updateAveragePower();
        updatePowerTimer.start();

        EnergyLog.init();
        addEnergyEntry("Start");
        addEnergyEntry(status);
        updateAverageEnergy();
        updateEnergyTimer.start();

        initialized = true;
    }

    function reset()
    {
        PowerLog.reset();
        updateAveragePower();
        EnergyLog.reset();
        updateAverageEnergy();
    }

    function updateAveragePower()
    {
        averagePowerTrend = (full ? 0.0 : PowerLog.getAveragePower());
        remainingMinutesTrend = getRemainingMinutes(averagePowerTrend);
        remainingTimeTrendShort = TimeFormat.getShortTimeString(remainingMinutesTrend);
        remainingTimeTrendLong = TimeFormat.getLongTimeString(remainingMinutesTrend);

        averagePowerUpdated();
    }

    function updateAverageEnergy()
    {
        averagePowerPrognosis = EnergyLog.getAveragePower(1);

        // switch to averagePowerTrend if averagePowerPrognosis is not available
        if (averagePowerPrognosis < 1 && !charging)
            averagePowerPrognosis = averagePowerTrend;

        remainingMinutesPrognosis = getRemainingMinutes(averagePowerPrognosis);
        remainingTimePrognosisShort = TimeFormat.getShortTimeString(remainingMinutesPrognosis);
        remainingTimePrognosisLong = TimeFormat.getLongTimeString(remainingMinutesPrognosis);

        remainingMinutesFullPrognosis = getRemainingMinutesDischargingFull(averagePowerPrognosis);
        remainingTimeFullPrognosisShort = TimeFormat.getShortTimeString(remainingMinutesFullPrognosis);
        remainingTimeFullPrognosisLong = TimeFormat.getLongTimeString(remainingMinutesFullPrognosis);

        averageEnergyUpdated();
    }

    function addPowerEntry()
    {
        PowerLog.addEntry(power);
    }

    function addEnergyEntry(event)
    {
        var eventTime = EnergyLog.addEntry(energy, charging, active, event);
        if (initialized && eventTime !== 0)
        {
            energyEventAdded(eventTime, energy, charging, event);

            if (event === "")
                EnergyLog.cleanup(settings.energyLogDayCount);
        }
    }

    function getRemainingMinutes(averagePower)
    {
        // charging
        if (averagePower < 0.0)
            return Math.round(60.0 * ((batteryInfo.energyFull - batteryInfo.energy) / Math.abs(averagePower)));
        // discharging
        else if (averagePower > 0.0)
            return Math.round(60.0 * (batteryInfo.energy / averagePower));

        return 0.0;
    }

    function getRemainingMinutesDischargingFull(averagePower)
    {
        return Math.round(60.0 * (batteryInfo.energyFull / averagePower));
    }

    function getLatestEnergyEntries(dayCount, dayOffset)
    {
        return EnergyLog.getLatestEntries(dayCount, dayOffset);
    }

    function getLatestEnergyEvents(dayCount)
    {
        return EnergyLog.getLatestEvents(dayCount);
    }

    // -----------------------------------------------------------------------

    onStatusChanged:
    {
        if (!initialized)
            return;

        addEnergyEntry(status);
        updateAverageEnergy();
        updateEnergyTimer.start();
    }
    onActiveChanged:
    {
        if (!initialized)
            return;

        addEnergyEntry("");
        updateAverageEnergy();
        updateEnergyTimer.start();
    }
    onCapacityChanged:
    {
        if (!initialized)
            return;

        capacityUpdated();
    }
    Component.onDestruction:
    {
        // note: this piece code is not called reliably
        addEnergyEntry("Stop");
    }

    // -----------------------------------------------------------------------

    Timer
    {
        id: updatePowerTimer

        interval: Globals.UPDATE_POWER_INTERVAL * 1000
        repeat: true
        onTriggered: {
            screenInfo.update();
            batteryInfo.update();
            addPowerEntry();
            updateAveragePower();
        }
    }
    Timer
    {
        id: updateEnergyTimer

        interval: Globals.UPDATE_ENERGY_INTERVAL * 1000
        repeat: true
        onTriggered: {
            screenInfo.update();
            batteryInfo.update();
            addEnergyEntry("");
            updateAverageEnergy();
        }
    }
}
