![ReSignMe icon](http://lonnygomes.github.io/images/apps/iconReSignMe_128.png) ReSignMe iOS App Re-signer
==========================

ReSignMe is an OS X app that simplifies the process of re-signing an iOS app down to a few clicks of the mouse. The user is able to drag any ad-hoc signed ipa into the app and re-sign it with one click. The goal of this app is to be as easy as possible to use. There is [Documentation] (http://github.com/LonnyGomes/ReSignMe/wiki/Documentation) for basic instructions on using the app and all of it's options.

![ReSignMe Screen Shot](http://lonnygomes.github.io/screenshots/screenShot1_ReSignMe.png "ReSignMe App")

## Use Cases ##
ReSignMe was created to be used in situations where apps are signed with ad-hoc distribution certificates. Some potential scenarios are:

  * a corporate environments internal apps are developed 
    * apps whose certs have expired could be easily re-signed without rebuilding
  * an iOS developers distributing ipa files to testers

This app is currently in beta mode. I am in search of volunteers to help test the app. It can resign an app but does implement extra features such as re-signing with a new mobile provisioning profile or specifying entitlements.

## Dependencies ##
  * OS X 10.7 (Lion) or Greater
  * Xcode 4
  * Xcode command line tools
  * installed iPhone distribution and/or developer certificates

## Features ##
  * drag and drop interface
  * re-sign multipe apps as a batch process
  * auto detection of Xcode
  * automatically loads iPhone certificates from Keychain
  * verbose output options
  * open in finder option after re-signing

## Roadmap ##
  * adding an "Advanced" mode that contains the following features
    * adding an option to replace mobile provisioning profile
    * adding the ability to "rewrite" the bundle header
    * add ability to specify an entitlement
  * adding help
  * adding preferences
