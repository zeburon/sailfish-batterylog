import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem
{
    id: backgroundItem

    // -----------------------------------------------------------------------

    property color colorValue
    property string colorLabel

    // -----------------------------------------------------------------------

    onClicked:
    {
        var page = pageStack.push(colorChooserDialog, { colorValue: backgroundItem.colorValue })
        page.accepted.connect(function()
        {
            backgroundItem.colorValue = page.colorValue;
            pageStack.pop()
        });
    }

    // -----------------------------------------------------------------------

    Component
    {
        id: colorChooserDialog

        ColorChooserDialog
        {
        }
    }

    Row
    {
        x: Theme.horizontalPageMargin
        height: parent.height
        spacing: Theme.paddingMedium

        Rectangle
        {
            id: colorIndicator

            anchors { verticalCenter: parent.verticalCenter }
            width: height
            height: parent.height - Theme.paddingMedium
            radius: width / 2
            color: colorValue
        }
        Label
        {
            text: colorLabel
            color: backgroundItem.down ? Theme.highlightColor : Theme.primaryColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
