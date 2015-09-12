import QtQuick 2.0
import Sailfish.Silica 1.0

Item
{
    property color itemColor
    property string itemLabel

    Rectangle
    {
        id: example

        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        width: height
        height: parent.height
        radius: width / 2
        color: itemColor
    }
    Label
    {
        anchors { right: example.left; rightMargin: 4; left: parent.left; verticalCenter: parent.verticalCenter }
        text: itemLabel
        color: Theme.secondaryColor
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font { family: Theme.fontFamily; pixelSize: Theme.fontSizeTiny }
    }
}
