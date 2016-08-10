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
import harbour.usb.switch.dbus 2.0

import "components"
import "pages"

ApplicationWindow
{
    id:app
    property string current_mode: ''
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    Component.onDestruction: mceControl.allowDisplayBlanking()

    DBusInterface {

        id: usbControl
        service: "com.meego.usb_moded"
        path: "/com/meego/usb_moded"
        iface: "com.meego.usb_moded"
        bus: DBusInterface.SystemBus
        signalsEnabled: true

        property string currentMode: ''
        property var availableModes: []

        function setMode(mode) {
            console.log("setting mode to " + mode)
            call('set_mode', [mode]);
        }

        function getMode() {
            console.log("getting current mode " + currentMode)
            return currentMode;
        }

        function isModeAvailable(mode) {
            for(var i=0; i<availableModes.length; i++) {
                if(availableModes[i] === mode) return true;
            }
            return false;
        }

        function sig_usb_state_ind(mode) {
            console.log("mode has changed to " + mode)
            currentMode = mode;
        }

        function init() {
            if(currentMode.length === 0) {
                console.debug("requesting available modes");
                typedCall('get_modes', [], function (modes) {
                    console.debug("available modes are " + modes);
                    availableModes = modes.split(/,\s*/);
                });
                console.debug("requesting current mode");
                typedCall('mode_request', [], function (mode) {
                    console.debug("current mode is " + mode);
                    currentMode = mode;
                });
            }
        }

    }

    DBusInterface {
        id: mceControl
        service: "com.nokia.mce"
        path: "/com/nokia/mce/request"
        iface: "com.nokia.mce.request"
        bus: DBusInterface.SystemBus

        signalsEnabled: true

        property string currentBlankingStatus: ''

        function preventDisplayBlanking() {
                    console.log("prevent display blanking")
                    call('req_display_blanking_pause', undefined)
                    currentBlankingStatus = 'paused'
        }

        function allowDisplayBlanking() {
                    console.log("allow display blanking")
                    call('req_display_cancel_blanking_pause', undefined)
                    currentBlankingStatus = 'allowed'
        }


    }
    Timer {
        running: true
        interval: 200
        onTriggered: {
            usbControl.init();
            mceControl.allowDisplayBlanking();
        }
    }
}



