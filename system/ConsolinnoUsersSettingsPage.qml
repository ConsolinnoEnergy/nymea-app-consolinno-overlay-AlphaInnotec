import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("User settings")

    UserManager {
        id: userManager
        engine: _engine

        onChangePasswordReply: {
            if (error !== UserManager.UserErrorNoError) {
                var component = Qt.createComponent("../components/ErrorDialog.qml")
                var text;
                switch (error) {
                case UserManager.UserErrorBadPassword:
                    text = qsTr("The given password is not valid.");
                    break;
                case UserManager.UserErrorPermissionDenied:
                    text = qsTr("Permission denied.");
                    break;
                case UserManager.UserErrorBackendError:
                    text = qsTr("The new password could not be stored.")
                    break;
                default:
                    text = qsTr("Un unexpected error happened when changing the password. We're sorry for this. (Error code: %1)").arg(error);
                    break;
                }

                var popup = component.createObject(app, {text: text});
                popup.open()
            }
        }

    }

    RowLayout {
        Layout.margins: Style.margins
        spacing: Style.margins
        //visible: !engine.jsonRpcClient.pushButtonAuthAvailable
        ColorIcon {
            size: Style.hugeIconSize
            source: "../images/account.svg"
            color: Style.accentColor
        }
        ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: userManager.userInfo.displayName || userManager.userInfo.username
                font: Style.bigFont
            }
            Label {
                Layout.fillWidth: true
                text: userManager.userInfo.username
                visible: userManager.userInfo.displayName !== ""
            }
            Label {
                Layout.fillWidth: true
                text: userManager.userInfo.email
                font: Style.smallFont
            }
        }
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Change password")
        iconName: "../images/key.svg"
        //visible: !engine.jsonRpcClient.pushButtonAuthAvailable
        onClicked: {
            var page = pageStack.push(changePasswordComponent)
            page.confirmed.connect(function(newPassword) {
                userManager.changePassword(newPassword)
            })
        }
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Edit user information")
        iconName: "../images/edit.svg"
        onClicked: pageStack.push(editUserInfoComponent)
        visible: !engine.jsonRpcClient.pushButtonAuthAvailable
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Manage authorized devices")
        iconName: "../images/smartphone.svg"
        onClicked: {
            pageStack.push(manageTokensComponent)
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Admin")
        visible: (userManager.userInfo.scopes & UserInfo.PermissionScopeAdmin) //&& !engine.jsonRpcClient.pushButtonAuthAvailable
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Manage users")
        visible: (userManager.userInfo.scopes & UserInfo.PermissionScopeAdmin) //&& !engine.jsonRpcClient.pushButtonAuthAvailable
        iconName: "../images/contact-group.svg"
        onClicked: {
            pageStack.push(manageUsersComponent)
        }
    }

    Component {
        id: editUserInfoComponent
        SettingsPageBase {
            id: editUserInfoPage
            title: qsTr("Edit user information")
            GridLayout {
                Layout.margins: Style.margins
                columnSpacing: Style.margins
                columns: 2
                Label {
                    text: qsTr("Your name")
                }
                NymeaTextField {
                    id: displayNameTextField
                    Layout.fillWidth: true
                    text: userManager.userInfo.displayName
                }
                Label {
                    text: qsTr("Email")
                }
                NymeaTextField {
                    id: emailTextField
                    Layout.fillWidth: true
                    text: userManager.userInfo.email
                }
            }
            Button {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("OK")
                onClicked: {
                    editUserInfoPage.busy = true
                    userManager.setUserInfo(userManager.userInfo.username, displayNameTextField.text, emailTextField.text)
                }
            }
            Connections {
                target: userManager
                onSetUserInfoReply: {
                    editUserInfoPage.busy = false
                    if (error != UserManager.UserErrorNoError) {
                        var component = Qt.createComponent("../components/ErrorDialog.qml")
                        var text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                        var popup = component.createObject(app, {text: text});
                        popup.open()
                    } else {
                        pageStack.pop()
                    }
                }
            }
        }
    }

    Component {
        id: changePasswordComponent
        SettingsPageBase {
            id: changePasswordPage
            title: qsTr("Change password")

            signal confirmed(string newPassword)

            SettingsPageSectionHeader {
                text: qsTr("Change password")
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Please enter the new password for %1").arg(userManager.userInfo.username)
                wrapMode: Text.WordWrap
            }

            ConsolinnoPasswordTextField {
                id: passwordTextField
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                minPasswordLength: 8
                requireLowerCaseLetter: true
                requireUpperCaseLetter: true
                requireNumber: true
                requireSpecialChar: false
                signup: true
            }

            Button {
                text: qsTr("OK")
                Layout.fillWidth: true
                Layout.margins: app.margins
                enabled: passwordTextField.isValid
                onClicked: {
                    changePasswordPage.confirmed(passwordTextField.password)
                    pageStack.pop();
                }
            }
        }
    }

    Component {
        id: manageTokensComponent
        SettingsPageBase {
            id: manageTokensPage
            title: qsTr("Device access")

            Component {
                id: confirmTokenDeletionComponent
                NymeaDialog {
                    headerIcon: "../images/lock-closed.svg"
                    title: qsTr("Remove device access")
                    text: qsTr("Are you sure you want to remove %1 from accessing your %2 system?").arg("<b>" + tokenInfo.deviceName + "</b>").arg(Configuration.systemName)
                    property TokenInfo tokenInfo: null
                    standardButtons: Dialog.Yes | Dialog.No
                    onAccepted: {
                        userManager.removeToken(tokenInfo.id)
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Devices / Apps accessing %1").arg(Configuration.systemName)
            }

            Repeater {
                model: userManager.tokenInfos

                delegate: NymeaSwipeDelegate {
                    Layout.fillWidth: true
                    text: model.deviceName
                    subText: qsTr("Created on %1").arg(Qt.formatDateTime(model.creationTime, Qt.DefaultLocaleShortDate))
                    prominentSubText: false
                    progressive: false
                    canDelete: true
                    iconName: "../images/smartphone.svg"

                    onClicked: deleteClicked()
                    onDeleteClicked: {
                        var popup = confirmTokenDeletionComponent.createObject(manageTokensPage, {tokenInfo: userManager.tokenInfos.get(index)})
                        popup.open()
                    }
                }
            }
        }
    }

    Component {
        id: manageUsersComponent
        SettingsPageBase {
            id: manageUsersPage

            header: NymeaHeader {
                text: qsTr("Users")
                onBackPressed: pageStack.pop()

                HeaderButton {
                    imageSource: Qt.resolvedUrl("../images/add.svg")
                    onClicked: {
                        var page = pageStack.push(addUserComponent)
                        page.done.connect(function(){
                            reloadUserList()
                            pageStack.pop()


                        })
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Manage users for this %1 system").arg(Configuration.systemName)
            }

            ListModel{
                id: users

            }

            Component.onCompleted: {
                reloadUserList()

            }

            function reloadUserList(){

                // empty the ListModel so it can reload
                users.clear()


                //header.text = userManager.users.count
                for(var i = 0; i < userManager.users.count  ; i++ ){

                    if (userManager.users.get(i)){

                        users.append(userManager.users.get(i))
                    }
                }
            }

            Repeater {
                id: userRepeater
                model: users
                delegate: NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.ensureServerVersion("6.0") && model.displayName !== "" ? model.displayName : model.username !== "" ? model.username : qsTr("User login via authentication")
                    subText: engine.jsonRpcClient.ensureServerVersion("6.0") && model.displayName ? model.username : ""
                    iconName: "/ui/images/account.svg"
                    iconColor: userManager.userInfo.scopes & UserInfo.PermissionScopeAdmin ? Style.accentColor : Style.iconColor

                    canDelete: true
                    onClicked: {
                        var page = pageStack.push(userDetailsComponent, {userInfo: userManager.users.get(index)})
                        page.done.connect(function(){
                            reloadUserList()
                            pageStack.pop()
                        })
                    }
                }
            }
        }
    }

    Component {
        id: userDetailsComponent

        SettingsPageBase {
            id: userDetailsPage
            title: userInfo.username ? qsTr("Manage %1").arg(userInfo.username) : qsTr("Authenticated user")
            signal done

            property UserInfo userInfo: null

            Component {
                id: confirmUserDeletionComponent
                NymeaDialog {
                    headerIcon: "../images/lock-closed.svg"
                    title: qsTr("Remove user")
                    text: qsTr("Are you sure you want to remove %1 from accessing your %2 system?").arg("<b>" + userInfo.username + "</b>").arg(Configuration.systemName)
                    property UserInfo userInfo: null
                    standardButtons: Dialog.Yes | Dialog.No
                    onAccepted: {
                        userDetailsPage.busy = true
                        userManager.removeUser(userInfo.username)
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("User information for %1").arg(userDetailsPage.userInfo.username)
            }

            GridLayout {
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                columnSpacing: Style.margins
                columns: 2
                Label {
                    text: qsTr("Name")
                }
                NymeaTextField {
                    id: displayNameTextField
                    Layout.fillWidth: true
                    text: userDetailsPage.userInfo.displayName
                }
                Label {
                    text: qsTr("Email")
                }
                NymeaTextField {
                    id: emailTextField
                    Layout.fillWidth: true
                    text: userDetailsPage.userInfo.email
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("Save")
                onClicked: {
                    userManager.setUserInfo(userDetailsPage.userInfo.username, displayNameTextField.text, emailTextField.text)
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Remove")
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                text: qsTr("Remove this user")
                onClicked: {
                    var popup = confirmUserDeletionComponent.createObject(userDetailsPage, {userInfo: userDetailsPage.userInfo})
                    popup.open()
                }
            }

            Connections {
                target: userManager
                onRemoveUserReply: {
                    userDetailsPage.busy = false
                    if (error !== UserManager.UserErrorNoError) {
                        var component = Qt.createComponent("../components/ErrorDialog.qml")
                        var text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                        var popup = component.createObject(app, {text: text});
                        popup.open()
                    } else {
                        userDetailsPage.done()
                        //pageStack.pop();
                    }
                }
            }
        }
    }

    Component {
        id: addUserComponent

        SettingsPageBase {
            id: createUserPage
            title: qsTr("Add a user")

            signal done
            // Consolinno change: New users are admin by default.
            property var permissionScopes: UserInfo.PermissionScopeAdmin

            SettingsPageSectionHeader {
                text: qsTr("User information")
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                columns: 2
                Label {
                    text: qsTr("Username:") + "*"
                }
                TextField {
                    id: usernameTextField
                    Layout.fillWidth: true

                    //inputMethodHints: Qt.ImhLowercaseOnly
                }

                Label {
                    text: qsTr("Password:") + "*"
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: Style.smallMargins
                }
                ConsolinnoPasswordTextField {
                    id: passwordTextField
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Full name:")
                }
                TextField {
                    id: displayNameTextField
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("e-mail:")
                }
                TextField {
                    id: emailTextField
                    Layout.fillWidth: true
                }
            }

            Button {
                text: qsTr("Create new user")
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                enabled: usernameTextField.length >= 3 && passwordTextField.isValid
                onClicked: {
                    createUserPage.busy = true
                    // TOFIX: IT is not possible to give usernameTextField an Uppercase. Otherwise the function just is very buggy
                    // Also not allowed are: Special character (!"§), german specific signs (?ÄÜ)
                    userManager.createUser(usernameTextField.text.toLowerCase(), passwordTextField.password, displayNameTextField.text, emailTextField.text, createUserPage.permissionScopes)
                }
            }

            Connections {
                target: userManager
                onCreateUserReply: {
                    createUserPage.busy = false
                    if (error !== UserManager.UserErrorNoError) {
                        var component = Qt.createComponent("../components/ErrorDialog.qml")
                        var text;
                        switch (error) {
                        case UserManager.UserErrorInvalidUserId:
                            text = qsTr("The given username is not valid. It needs to be at least three characters long and not contain special characters.");
                            break;
                        case UserManager.UserErrorDuplicateUserId:
                            text = qsTr("The given username is already in use. Please choose a different username.");
                            break;
                        case UserManager.UserErrorBadPassword:
                            text = qsTr("The given password is not valid.");
                            break;
                        case UserManager.UserErrorPermissionDenied:
                            text = qsTr("Permission denied.");
                            break;
                        default:
                            text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                            break;
                        }

                        var popup = component.createObject(app, {text: text});
                        popup.open()
                    } else {
                        createUserPage.done()
                        //pageStack.pop();

                    }
                }
            }
        }
    }
}
