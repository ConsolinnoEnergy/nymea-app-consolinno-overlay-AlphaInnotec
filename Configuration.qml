pragma Singleton

import QtQuick 2.0

ConfigurationBase {
    systemName: "Leaflet"
    appName: "AlphaInnotec Konfigurationsassistent"
    appId: "com.consolinno.energy"

    //connectionWizard: "/ui/wizards/ConnectionWizard.qml"
    connectionWizard: "/ui/connection/NewConnectionWizard.qml"

    // Identifier used for branding (e.g. to register for push notifications)
    property string branding: "consolinno"

    // Branding names visible to the user
    property string appBranding: "Consolinno Energy"
    property string coreBranding: "Leaflet"

    // Additional MainViews
    property var additionalMainViews: ListModel {
        ListElement { name: "AlphaInnotec"; source: "AlphaInnotecHeatPump"; displayName: qsTr("Consolinno"); icon: "leaf" }
    }

    // Main views filter: Only those main views are enabled
    //property var mainViewsFilter: [ "consolinno", "things" ]
    property var mainViewsFilter: ["AlphaInnotec"]
}
