// helper functions for generating time strings

// -----------------------------------------------------------------------

function getLongTimeString(minutes)
{
    if (isNaN(minutes))
        minutes = 0;

    if (minutes > 60 * 24 * 31)
        return "?";

    if (minutes <= 60)
        return qsTr("%1 minute(s)").arg(minutes);

    var hours = Math.floor(minutes / 60);
    minutes -= hours * 60;
    if (hours < 24)
        return qsTr("%1 hour(s)").arg(hours) + ((minutes === 0) ? "" : qsTr(" and ") + qsTr("%1 minute(s)").arg(minutes));

    var days = Math.floor(hours / 24);
    hours -= days * 24;
    return qsTr("%1 day(s)").arg(days) + ((hours === 0) ? "": qsTr(" and ") + qsTr("%1 hour(s)").arg(hours));
}

// -----------------------------------------------------------------------

function getShortTimeString(minutes)
{
    if (isNaN(minutes))
        minutes = 0;

    if (minutes < 1)
        return "--:--";

    if (minutes > 60 * 24 * 31)
        return "?";

    if (minutes > 60 * 72)
    {
        var days = minutes / 60 / 24;
        return qsTr("%1 day(s)").arg(days.toFixed(1));
    }
    else
    {
        var hours = Math.floor(minutes / 60);
        minutes -= hours * 60;
        return qsTr("%1:%2").arg(hours > 9 ? hours : "0" + hours).arg(minutes > 9 ? minutes : "0" + minutes);
    }
}
