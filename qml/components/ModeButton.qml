/*
    USB Switch - a simple USB mode switcher for SailfishOS
    Copyright (C) 2014 - 2015 Jens Klingen

    https://github.com/jklingen/harbour-usb-switch

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0


IconButton {
    property string modeName
    property string text
    property string iconName

    visible: usbControl.isModeAvailable(modeName)
    width:parent.width
    height: page.height / (usbControl.availableModes.length + 1)
    onClicked: {
        usbControl.setMode(modeName)
        if (usbControl.currentMode == 'developer_mode') {
           (mceControl.currentBlankingStatus == 'allowed'? mceControl.preventDisplayBlanking() : mceControl.allowDisplayBlanking());
        }
    }
    icon.source:'image://theme/' + iconName + '?' + ((parent.pressed || usbControl.currentMode === modeName) ? Theme.highlightColor : Theme.primaryColor)
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        color: (parent.pressed || usbControl.currentMode === parent.modeName) ? Theme.highlightColor : Theme.primaryColor
        text:parent.text + ((mceControl.currentBlankingStatus == 'paused' && usbControl.currentMode == 'developer_mode' && iconName == 'icon-l-developer-mode')?" - Display On":"")
    }
    Rectangle {
        width:parent.width
        height:parent.height-2*Theme.paddingLarge
        color:Theme.secondaryHighlightColor
        opacity: parent.pressed ? .25 : 0
    }
}
