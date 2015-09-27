import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    // -----------------------------------------------------------------------

    property color colorValue
    property bool initialized: false

    // -----------------------------------------------------------------------

    function updateColorValue()
    {
        if (initialized)
        {
            colorValue.r = redSlider.value / 255;
            colorValue.g = greenSlider.value / 255;
            colorValue.b = blueSlider.value / 255;
            colorValue.a = alphaSlider.value / 255;
        }
    }

    // -----------------------------------------------------------------------

    canAccept: true
    onOpened:
    {
        redSlider.value   = colorValue.r * 255
        greenSlider.value = colorValue.g * 255
        blueSlider.value  = colorValue.b * 255
        alphaSlider.value = colorValue.a * 255
        initialized = true;
    }

    // -----------------------------------------------------------------------

    Column
    {
        id: column

        width: parent.width
        spacing: Theme.paddingSmall

        DialogHeader
        {
        }
        Slider
        {
            id: redSlider

            minimumValue: 0
            maximumValue: 255
            stepSize: 1
            enabled: true
            width: parent.width
            handleVisible: true
            valueText: value.toFixed(0)
            label: qsTr("Red")
            onValueChanged:
            {
                updateColorValue();
            }
        }
        Slider
        {
            id: greenSlider

            minimumValue: 0
            maximumValue: 255
            stepSize: 1
            enabled: true
            width: parent.width
            handleVisible: true
            valueText: value.toFixed(0)
            label: qsTr("Green")
            onValueChanged:
            {
                updateColorValue();
            }
        }
        Slider
        {
            id: blueSlider

            minimumValue: 0
            maximumValue: 255
            stepSize: 1
            enabled: true
            width: parent.width
            handleVisible: true
            valueText: value.toFixed(0)
            label: qsTr("Blue")
            onValueChanged:
            {
                updateColorValue();
            }
        }
        Slider
        {
            id: alphaSlider

            minimumValue: 0
            maximumValue: 255
            stepSize: 1
            enabled: true
            width: parent.width
            handleVisible: true
            valueText: value.toFixed(0)
            label: qsTr("Alpha")
            onValueChanged:
            {
                updateColorValue();
            }
        }
    }
    Item
    {
        anchors { left: parent.left; right: parent.right; top: column.bottom; bottom: parent.bottom }

        Rectangle
        {
            id: colorIndicator

            anchors { centerIn: parent }
            width: 100
            height: 100
            radius: width / 2
            color: colorValue
        }
    }
}
