var maximumEntryCount = 10;
var lastPowerValues   = [];
var lastCharging      = false;

// -----------------------------------------------------------------------

function init()
{
}

// -----------------------------------------------------------------------

function reset()
{
    lastPowerValues = [];
}

// -----------------------------------------------------------------------

function addEntry(power)
{
    var currentlyCharging = (power < 0.0);
    if (currentlyCharging != lastCharging)
    {
        lastPowerValues = [];
        lastCharging = currentlyCharging;
    }

    lastPowerValues.push(power);
    if (lastPowerValues.length >= maximumEntryCount * 2)
    {
        lastPowerValues = lastPowerValues.slice(maximumEntryCount);
    }
}

// -----------------------------------------------------------------------

function getWeightedAverage(count)
{
    count = Math.min(count, lastPowerValues.length);
    if (count < 1)
        return 0.0;

    var startIdx = lastPowerValues.length - count;
    var endIdx = lastPowerValues.length;
    var valueSum = 0, weightSum = 0;
    for (var idx = 0; idx < count; ++idx)
    {
        valueSum += lastPowerValues[startIdx + idx] * idx; // latest values are more important
        weightSum += idx;
    }

    return Math.round(valueSum / weightSum);
}

// -----------------------------------------------------------------------

function getAveragePower()
{
    return getWeightedAverage(maximumEntryCount);
}
