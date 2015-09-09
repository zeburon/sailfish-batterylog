import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../globals.js" as Globals

Page
{
    id: page

    // -----------------------------------------------------------------------

    Column
    {
        id: column

        spacing: 5
        width: parent.width

        Item
        {
            width: 1
            height: Theme.fontSizeExtraLarge
        }
        Image
        {
            anchors { horizontalCenter: parent.horizontalCenter }
            source: "../gfx/about.png"
        }
        Label
        {
            id: titleLabel

            text: qsTr("Battery Log")
            anchors { horizontalCenter: parent.horizontalCenter }
            color: Theme.highlightColor
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeExtraLarge * 1.5 }
        }
        Label
        {
            text: qsTr("Version %1").arg(Globals.VERSION)
            anchors { horizontalCenter: titleLabel.horizontalCenter }
            color: Theme.secondaryHighlightColor
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeExtraLarge }
        }
        Label
        {
            text: qsTr("Copyright © 2015 Lukas Fraser")
            anchors { horizontalCenter: titleLabel.horizontalCenter }
            color: Theme.primaryColor
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeMedium }
        }
        Text
        {
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
            font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
            color: Theme.secondaryColor
            text: "<style>a:link { color: " + Theme.highlightColor + "; }</style><br/>" +
                qsTr("This program is open source software licensed under the terms of the GNU General Public License.") + "<br/><br/>" + qsTr("You can find the source code at the") +
                "<br/> <a href=\"https://github.com/zeburon/sailfish-batterylog\">" + qsTr("GitHub Project Page") + "</a>";
            onLinkActivated:
            {
                Qt.openUrlExternally(link);
            }
        }
    }
    Text
    {
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: Theme.paddingSmall }
        color: Theme.secondaryHighlightColor
        font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
        text: qsTr("Inspired by SailfishOS application Hunger Meter created by Michal Hrušecký.")
    }
}
