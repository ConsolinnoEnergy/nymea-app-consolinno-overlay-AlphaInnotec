APPLICATION_NAME=AlphaInnotecConnectionWizard
ORGANISATION_NAME=AlphaInnotec

PACKAGE_URN=com.consolinno.ait
PACKAGE_NAME=AlphaInnotec

IOS_BUNDLE_PREFIX=com.consolinno
IOS_BUNDLE_NAME=alphaInntotec


VERSION_INFO=$$cat(version.txt)
APP_VERSION=$$member(VERSION_INFO, 0)
APP_REVISION=$$member(VERSION_INFO, 1)

android {
    # Provides version_overlay.txt for Android build instead of nymea-app version.txt
    copydata.commands = $(COPY_DIR) $$PWD/version.txt $$OUT_PWD/version_overlay.txt
    first.depends = $(first) copydata
    export(first.depends)
    export(copydata.commands)
    QMAKE_EXTRA_TARGETS += first copydata
}
