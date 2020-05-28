# zcash-ios-wallet

iOS wallet using the Zcash iOS SDK that is maintained by core developers.

There are some known areas for improvement:

- Traffic analysis, like in other cryptocurrency wallets, can leak some privacy
  of the user.
- The wallet might display inaccurate transaction information if it is connected
  to an untrustworthy server.

See the [Wallet App Threat
Model](https://zcash.readthedocs.io/en/latest/rtd_pages/wallet_threat_model.html)
for more information about the security and privacy limitations of the wallet.

## Prerequisites
* make sure you can build ZcashLightClientKit Demo Apps successfully
* you must have a project in Firebase Crashlytics to build this app.

# Building the App
1. Clone the project, make sure you have the latest Xcode Version

2. Navigate to the wallet directory where the `Podfile` file is located and run `pod install`

3. open the `wallet.xcworkspace` file

4. locate the `.params` files that are missing in the project and include them at the specified locations

5. add the `GoogleService-Info.plist` from your Firebase Project into the XCWorkspace at the missing missing file location

6. build and run on simulator.
