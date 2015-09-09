import QtQuick 2.0

Canvas
{
    property int capacity: 100
    property real capacityPercent: capacity / 100.0
    property bool charging: false
    property real scaleX: 0.4
    property int offset: 6
    property color currentColor:
    {
        if (charging)
            return Qt.rgba(0.0, 1.0, 1.0, 1.0);

        if (capacityPercent >= 0.5)
        {
            var pGreen = Math.min(1.0, (capacityPercent - 0.5) * 4.0);
            return Qt.rgba(1.0 - pGreen, 1.0, 0.0, 1.0);
        }
        else if (capacityPercent > 0.1)
        {
            var pRed = Math.min(1.0, (capacityPercent - 0.1) * 4.0);
            return Qt.rgba(1.0, pRed, 0.0, 1.0);
        }
        return Qt.rgba(1.0, 0.0, 0.0, 1.0);
    }

    // -----------------------------------------------------------------------

    function refresh()
    {
        requestPaint();
    }

    function drawBackground(context, color)
    {
        var w = width;
        var h = height;
        var r = Math.round(h / 2.0);

        context.beginPath();
        context.rect(r * scaleX, 0.0, w - h * scaleX, h);
        context.fillStyle = color;
        context.fill();

        context.save();
        context.scale(scaleX, 1.0);
        context.beginPath();
        context.arc(r, r, r, Math.PI/2, Math.PI * 3 / 2, false);
        context.closePath();
        context.fillStyle = color;
        context.fill();
        context.restore();

        context.save();
        context.scale(scaleX, 1.0);
        context.beginPath();
        context.arc(w / scaleX - r, r, r, -Math.PI/2, Math.PI / 2, false);
        context.closePath();
        context.fillStyle = color;
        context.fill();
        context.restore();
    }

    function drawForeground(context, color, percent)
    {
        var h = height - offset * 2;
        var r = h / 2.0;
        var w = (width - r * scaleX * 2 - offset * 2) * percent;

        var gradient = context.createLinearGradient(0, 0, 0, height);
        gradient.addColorStop(0, color);
        gradient.addColorStop(0.2, Qt.lighter(color, 1.75));
        gradient.addColorStop(0.3, Qt.lighter(color, 1.75));
        gradient.addColorStop(0.4, color);
        gradient.addColorStop(0.6, Qt.darker(color, 1.2));
        gradient.addColorStop(1, Qt.darker(color, 2));

        // main section
        context.beginPath();
        context.rect(Math.floor(offset + r * scaleX), offset, w, h);
        context.fillStyle = gradient;
        context.fill();

        // left side
        context.save();
        context.scale(scaleX, 1.0);
        context.beginPath();
        context.arc(Math.floor(offset / scaleX + r), offset + r, r, Math.PI/2, Math.PI * 3 / 2, false);
        context.closePath();
        context.fillStyle = gradient;
        context.fill();
        context.restore();

        // right side
        context.save();
        context.scale(scaleX, 1.0);
        context.beginPath();
        context.arc((offset + w) / scaleX + r, offset + r, r, 0, Math.PI * 2, false);
        context.closePath();
        context.fillStyle = Qt.darker(color);
        context.fill();
        context.restore();
    }

    // -----------------------------------------------------------------------

    onPaint:
    {
        var context = getContext("2d");
        context.reset();

        drawBackground(context, Qt.rgba(currentColor.r * 0.1, currentColor.g * 0.1, currentColor.b * 0.1, 0.75));
        drawForeground(context, currentColor, capacityPercent);
    }
}
