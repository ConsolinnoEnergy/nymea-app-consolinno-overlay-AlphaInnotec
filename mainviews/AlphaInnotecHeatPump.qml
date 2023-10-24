import QtQuick 2.0
import "../components"



import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import Qt.labs.settings 1.1
import "../delegates"
import "qrc:/ui/devicepages"
import "../components"



MainViewBase {
    id: root

    Text {
        id: name
        text: heatpump.name
        anchors.centerIn: parent
    }



    ThingsProxy {
        engine: _engine
        id: heatpumps
        shownThingClassIds:["c04c3bce-065e-41a6-a312-9fe1cf3a4c10"]
    }


//    GenericDevicePage {
//        anchors.fill: parent
//        thing:heatpump
//        anchors.topMargin: root.topMargin
//    }



  readonly property Thing heatpump: heatpumps.count == 1 ? heatpumps.get(0) : null


    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("Es ist noch keine Wärmepumpe konfiguriert.")
        text: qsTr("Stellen Sie sicher, dass das Leaflet im selben Netzwerk verbunden ist, wie die Wärmepumpe.  ")
        imageSource: "qrc:/ui/images/thermostat/heating.svg"
        buttonText: qsTr("Wärmepumpe einrichten")
        visible: heatpumps.count === 0 && !engine.thingManager.fetchingData
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }




}

