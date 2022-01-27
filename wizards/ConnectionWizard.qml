import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    showBackButton: false
    showNextButton: false

    onNext: pageStack.push(findLeafletComponent)

    function exitWizard() {
        pageStack.pop(root, StackView.Immediate)
        pageStack.pop()
    }

    content: ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.topMargin: Style.margins
        spacing: Style.hugeMargins
        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
            source: "/ui/images/intro-bg-graphic.svg"
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width, 300)

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font: Style.bigFont
                text: qsTr("Leaflet")
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Stellen Sie sicher, dass das Leaflet betriebsbereit ist und mit dem Netzwerk verbunden ist.")
            }
            ConsolinnoButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Start setup")
                onClicked: root.next()
            }
        }
    }

    Component {
        id: findLeafletComponent

        ConsolinnoWizardPageBase {
            id: findLeafletPage
            onBack: pageStack.pop()
            nextButtonText: qsTr("Manuelle Verbindung")
            onNext: pageStack.push(manualConnectionComponent)

            Timer {
                id: timeoutTimer
                interval: 15000
                running: hostsProxy.count == 0
                onTriggered: pageStack.pop()
            }

            content: ColumnLayout {
                anchors.fill: parent


                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    wrapMode: Text.WordWrap
                    text: hostsProxy.count === 0
                          ? qsTr("Auf der Suche nach Ihrem Leaflet...")
                          : qsTr("Wir haben mehrere Leaflets im Netzwerk entdeckt. Bitte wählen Sie das gewünschte aus.")
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: NymeaHostsFilterModel {
                        id: hostsProxy
                        discovery: nymeaDiscovery
                        showUnreachableBearers: false
                        jsonRpcClient: engine.jsonRpcClient
                        showUnreachableHosts: false

                        /*onCountChanged: {
                            if (count === 1) {
                                engine.jsonRpcClient.connectToHost(hostsProxy.get(0))
                            }
                        }*/
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width
                        visible: hostsProxy.count == 0
                        spacing: Style.margins
                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.margins: Style.margins
                            text: qsTr("Bitte warten Sie, während Ihr Leaflet entdeckt wird.")
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }


                    delegate: NymeaSwipeDelegate {
                        id: nymeaHostDelegate
                        width: parent.width
                        property var nymeaHost: hostsProxy.get(index)
                        property string defaultConnectionIndex: {
                            var bestIndex = -1
                            var bestPriority = 0;
                            for (var i = 0; i < nymeaHost.connections.count; i++) {
                                var connection = nymeaHost.connections.get(i);
                                if (bestIndex === -1 || connection.priority > bestPriority) {
                                    bestIndex = i;
                                    bestPriority = connection.priority;
                                }
                            }
                            return bestIndex;
                        }
                        iconName: {
                            if (!nymeaHost) {
                                return
                            }
                            switch (nymeaHost.connections.get(defaultConnectionIndex).bearerType) {
                            case Connection.BearerTypeLan:
                            case Connection.BearerTypeWan:
                                if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                    return "/ui/images/connections/network-wired.svg"
                                }
                                return "/ui/images/connections/network-wifi.svg";
                            case Connection.BearerTypeBluetooth:
                                return "/ui/images/connections/bluetooth.svg";
                            case Connection.BearerTypeCloud:
                                return "/ui/images/connections/cloud.svg"
                            case Connection.BearerTypeLoopback:
                                return "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                            }
                            return ""
                        }
                        text: model.name
                        subText: nymeaHost.connections.get(defaultConnectionIndex).url
                        wrapTexts: false
                        prominentSubText: false
                        progressive: false
                        property bool isSecure: nymeaHost.connections.get(defaultConnectionIndex).secure
                        property bool isOnline: nymeaHost.connections.get(defaultConnectionIndex).bearerType !== Connection.BearerTypeWan ? nymeaHost.connections.get(defaultConnectionIndex).online : true
                        tertiaryIconName: isSecure ? "/ui/images/connections/network-secure.svg" : ""
                        secondaryIconName: !isOnline ? "/ui/images/connections/cloud-error.svg" : ""
                        secondaryIconColor: "red"

                        onClicked: {
                            engine.jsonRpcClient.connectToHost(nymeaHostDelegate.nymeaHost)
                        }

                        contextOptions: [
                            {
                                text: qsTr("Info"),
                                icon: Qt.resolvedUrl("/ui/images/info.svg"),
                                callback: function() {
                                    var nymeaHost = hostsProxy.get(index);
                                    var connectionInfoDialog = Qt.createComponent("/ui/components/ConnectionInfoDialog.qml")
                                    var popup = connectionInfoDialog.createObject(app,{nymeaHost: nymeaHost})
                                    console.warn("::", connectionInfoDialog.errorString())
                                    popup.open()
                                }
                            }
                        ]
                    }
                }
            }
        }
    }

    Component {
        id: manualConnectionComponent
        ConsolinnoWizardPageBase {
//            title: qsTr("Manual connection")
//            text: qsTr("Please enter the connection information for your nymea system")
            onBack: pageStack.pop()

            onNext: {
                var rpcUrl
                var hostAddress
                var port

                // Set default to placeholder
                if (addressTextInput.text === "") {
                    hostAddress = addressTextInput.placeholderText
                } else {
                    hostAddress = addressTextInput.text
                }

                if (portTextInput.text === "") {
                    port = portTextInput.placeholderText
                } else {
                    port = portTextInput.text
                }

                if (connectionTypeComboBox.currentIndex == 0) {
                    if (secureCheckBox.checked) {
                        rpcUrl = "nymeas://" + hostAddress + ":" + port
                    } else {
                        rpcUrl = "nymea://" + hostAddress + ":" + port
                    }
                } else if (connectionTypeComboBox.currentIndex == 1) {
                    if (secureCheckBox.checked) {
                        rpcUrl = "wss://" + hostAddress + ":" + port
                    } else {
                        rpcUrl = "ws://" + hostAddress + ":" + port
                    }
                }

                print("Try to connect ", rpcUrl)
                var host = nymeaDiscovery.nymeaHosts.createWanHost("Manuelle Verbindung", rpcUrl);
                engine.jsonRpcClient.connectToHost(host)
            }

            content: ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                GridLayout {
                    columns: 2

                    Label {
                        text: qsTr("Protocol")
                    }

                    ComboBox {
                        id: connectionTypeComboBox
                        Layout.fillWidth: true
                        model: [ qsTr("TCP"), qsTr("Websocket") ]
                    }

                    Label { text: qsTr("Adresse:") }
                    TextField {
                        id: addressTextInput
                        objectName: "addressTextInput"
                        Layout.fillWidth: true
                        placeholderText: "127.0.0.1"
                    }

                    Label { text: qsTr("Port:") }
                    TextField {
                        id: portTextInput
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex === 0 ? "2222" : "4444"
                        validator: IntValidator{bottom: 1; top: 65535;}
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Verschlüsselte Verbindung:")
                    }
                    CheckBox {
                        id: secureCheckBox
                        checked: true
                    }
                }
            }
        }
    }
}
