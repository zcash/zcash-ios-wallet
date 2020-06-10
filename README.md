# zcash-ios-wallet

## Motivation
Dogfooding - _transitive verb_ - is the practice of an organization using its own product. This app was created to help us learn.

Please take note: the wallet is not an official product by ECC, but rather a tool for learning about our libraries that it is built on. This means that we do not have robust infrasturcture or user support for this application. We open sourced it as a resource to make wallet development easier for the Zcash ecosystem.

## Description

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

# Building the App
1. Clone the project, make sure you have the latest Xcode Version

2. Create `env-vars.sh file` at `${SRCROOT}` [See Instructions](https://github.com/zcash/ZcashLightClientKit#setting-env-varsh-file-to-run-locally)

3. make sure that your environment has the variable `ZCASH_NETWORK_ENVIRONMENT` set to`MAINNET`or `TESTNET`.

4. Navigate to the wallet directory where the `Podfile` file is located and run `pod install`

5. open the `wallet.xcworkspace` file

6. locate the `.params` files that are missing in the project and include them at the specified locations

7. build and run on simulator.


## Troubleshooting

### No network environment....
if you see this message when building:
```No network environment. Set ZCASH_NETWORK_ENVIRONMENT to MAINNET or TESTNET```
make sure your dev environment has this variable set before the build starts. *DO NOT CHANGE IT DURING THE BUILD PROCESS*.

If the variable was properly set *after* you've seen this message, you will need to either a) set it manually on the pod's target or b) doing a clean pod install and subsequent build.

#### a) setting the flag manually
1. on your workspace, select the Pods project
2. on the Targets pane, select ZcashLightClientKit
3. go to build settings
4. scroll down to see ZCASH_NETWORK_ENVIRONMENT and complete with TESTNET or MAINNET
