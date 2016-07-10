import QtQuick 2.0
import Sailfish.Silica 1.0

Label
{
    property string categoryLabel

    width: contentWidth + Theme.paddingMedium
    text: categoryLabel
    color: Theme.primaryColor
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeTiny }
}
