ReSignMe iOS App Re-signer
==========================

ReSignMe is an OS X app that simplifies the process of re-signing an iOS app down to a few clicks of the mouse. The user is able to drag any ad-hoc signed ipa into the app and re-sign it with one click. The goal of this app is to be dead easy to use. It literally can be as easy as two mouse clicks to re-sign an app.

## Use Cases ##
ReSignMe was created to be used in an internal environment where apps are signed with enterprise distribution certificates. Since 

This app is currently in beta mode. It can resign an app but does not allow for any extra features such as resigning with a new mobile provisioning profile or specifying entitlements.

## Dependencies ##
  * OS X 10.7 (Lion) or Greater
  * Xcode 4
  * Xcode command line tools
  * installed iPhone distribution and/or developer certificates

## Features ##
  * drag and drop an IPA file
  * auto detect of Xcode
  * automatically loads iPhone certificates from Keychain
  * verbose output options
  * open in finder after re-signing


## Roadmap ##
  * adding an "Advanced" mode that contains the following features
    * adding an option to replace mobile provisioning profile
    * adding the ability to "rewrite" the bundle header
    * add ability to specify an entitlement
  * adding help
  * adding preferences
