pragma Singleton

import QtQml.Models 2.3

ConfigurationBase {
    systemName: "Leaflet"
    appName: "AlphaInnotec Konfigurationsassistent"
    appId: "com.consolinno.alphaInnotecConnectionWizard"

    connectionWizard: "/ui/wizards/ConnectionWizard.qml"
    //connectionWizard: "/ui/connection/NewConnectionWizard.qml"

    // Identifier used for branding (e.g. to register for push notifications)
    property string branding: "consolinno"

    // Branding names visible to the user
    property string appBranding: "Leaflet Konfigurationsassistent"
    property string coreBranding: "Leaflet"

    // Will be shown in About page
    property string githubLink: "https://github.com/ConsolinnoEnergy/nymea-app"
    property string privacyPolicyUrl: "https://consolinno.de/hems-datenschutz/"

    property ListModel softwareLinksApp: ListModel {
        ListElement { component: "Suru icons"; url: "https://github.com/snwh/suru-icon-theme" }
        ListElement { component: "Ubuntu font"; url: "https://design.ubuntu.com/font" }
        ListElement { component: "Oswald font"; url: "https://fonts.google.com/specimen/Oswald" }
        ListElement { component: "QTZeroConf"; url: "https://github.com/jbagg/QtZeroConf" }
        ListElement { component: "Android OpenSSL"; url: "https://github.com/KDAB/android_openssl" }
        ListElement { component: "Firebase"; url: "https://github.com/firebase/firebase-cpp-sdk" }
        ListElement { component: "OpenSSl"; url: "https://www.openssl.org/" }
        ListElement { component: "Nymea App"; url: "https://github.com/ConsolinnoEnergy/nymea-app" }
        ListElement { component: "Nymea Remoteproxy"; url: "https://github.com/ConsolinnoEnergy/nymea-remoteproxy" }
        ListElement { component: "Consolinno Overlay"; url: "https://github.com/ConsolinnoEnergy/nymea-app-consolinno-overlay-AlphaInnotec" }
    }

    property ListModel licensesApp: ListModel {
        ListElement { component: "GNU General Public License, Version 3.0"; license: "GPL3" }
        ListElement { component: "GNU Lesser General Public License, Version 3.0"; license: "LGPL3" }
        ListElement { component: "OpenSSL"; license: "OpenSSL" }
        ListElement { component: "Apache License, Version 2.0"; license: "APACHE2" }
        ListElement { component: "Creative Commons Attribution-ShareAlike 3.0 Unported"; license: "CC-BY-SA-3.0" }
        ListElement { component: "SIL Open Font License, Version 1.1"; license: "OFL" }
        ListElement { component: "Ubuntu font licence, Version 1.0"; license: "UFL" }
    }



    // Additional MainViews
    property var additionalMainViews: ListModel {
        ListElement { name: "AlphaInnotec"; source: "AlphaInnotecHeatPump"; displayName: qsTr("Consolinno"); icon: "leaf" }
    }

    // Main views filter: Only those main views are enabled
    //property var mainViewsFilter: [ "consolinno", "things" ]
    property var mainViewsFilter: [ "AlphaInnotec","things"]

    //defaultMainView:  "AlphaInnotec"


}
