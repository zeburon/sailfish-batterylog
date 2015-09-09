var lastPowerValues = [];
var lastCharging    = false;

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
    if (lastPowerValues.length >= 20)
    {
        lastPowerValues = lastPowerValues.slice(10);
    }
}

// -----------------------------------------------------------------------

function getAverage(count)
{
    if (lastPowerValues.length < 1)
        return 0.0;

    var rangeSum = 0;
    var startIdx = lastPowerValues.length - 1;
    var endIdx = Math.max(0, startIdx - count - 1);
    for (var idx = startIdx; idx >= endIdx; --idx)
    {
        rangeSum += lastPowerValues[idx];
    }
    var rangeCount = Math.max(1, startIdx - endIdx + 1);
    return Math.round(rangeSum / rangeCount);
}

// -----------------------------------------------------------------------

function getAverageNow()
{
    return getAverage(2);
}

// -----------------------------------------------------------------------

function getAverageTrend()
{
    return getAverage(10);
}
