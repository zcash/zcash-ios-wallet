# Changelog

##  0.4.0 build 116
* FIX: Issue #126 Download params instead of bundling them
* Fix Archive being broken
##  0.4.0 build 115
* Try to copy parameters from main bundle before entirely removing them
* update CombineUrlSessionDownloader
* Combine sapling downloaded plus tests. had to fix test schemes because they not build because of output files
* add combine downloader tests
* Remove Support for iOS 13 on logging targets
##  0.4.0 build 114
* Fix: Navigation Bar does not appear on balance breakdown screen Issue #275
##  0.4.0 build 113
 * fix build error on first build on clean repo
 * Fix rebase problem
 * Adopt Zcash SDK 0.12.0-alpha.3
## 0.3.7 build 110
* Issue #271 OhMyScreen shown after background tasks fails
## 0.3.7 build 109
* Fix Issue #269 - migration error recovery
* Issue #264
* AX Fix
* updated showing dropdown based on store and rcc teams
* Merge pull request #268 from zcash/shield-poc
* update travis.yml
* fix no-logging target compile error

## 0.3.7 build 108
* Fix Home Screen layout broken on large fonts
* Add validation errors to compactBlockProcessor
* Fix: Crash on background

## 0.3.7 build 107
* Implement wipe #263
## 0.3.7 build 106
* The UnScreen is a screen that let's you navigate to a safe place instead of crashing horribly
## 0.3.7 build 105
* fix: issue #277 crash when launching
## 0.3.7 build 104
* adopt create -> prepare API
* Make Bugsnag Great Again
* Fix: shielding screen acting weird
* Fix: issue #260 FlowError.InvalidEnvironment error when sending
* FIX: differenciate between TAZ and ZEC
## 0.3.7 build 102
* Fix #219 Biometrics Locked when user has no biometrics at all
* Use presentationMode to dismiss
* Remove Awesome Menu. fix Crash on launch
## 0.3.7 build 101
* don't spin up BG Tasks on simulator
* fix Wallet balance breakdown to highlight first n decimals
* Add target for testnet only
* add handled exception tracking to bugsnag
* add mixpanel events
* Fixed Received funds UI bug on tAddr accesory view. 
* Balance breakdown 


## 0.3.7 build 100
* Balance refactor

## 0.3.7 build 99
* fix wrong text, adjust title size, add accessory view for transparent
## 0.3.7 build 98
Receive from T Address
## 0.3.7 build 97
* Fixed: issue #241 screen says enter shielded when it can accept both


## 0.3.7 build 96
* make firstView() a ViewBuilder function
* comment useless preview
* Surface errors to UI
* Fix: error when backgrounding simulator
* Fix: don't display balance when syncing
* Fix Background Task warning when app loses focus but not foreground
* log initialization crash before crashing since appstore does not catch it
* Fix profile screen getting stuck after rescan starts


## 0.3.7 build 93
* change quick rescan to be one week of blocks
* [NEW] solicited feedback dialog
* Re scan feature
* Z->T restore

## 0.3.7 build 91
* save last used seetings and if user ever shielded
* Erase and rewind #247
* Add file logger (#244)
## 0.3.4 build 80
* Issue #239 show last used address when sending
* Issue #234 
* Issue #210
* Issue #197 Wallet History does not show up when app is offline
* wrong top padding on see details screen
* fix memory leak on reset
* Don't show network fee on received transaction
* Transaction Details as no top padding


## 0.3.4 build 75
* Wallet History Navigation reset fix
* Decouple Keypad and Home, add ZECCEnvironment as environmentValue
## 0.3.3 build 74
* send flow is cancelled when synchronizer finds a new block
* remove constants file from no-logging target
## 0.3.2 build 71\
* Fixes Issue #215 - Can't paste into the memo field
* Fixes Issue #213
* fixes Issue #220
* Fixes Issue #216 Touching payment address to copy to clipboard doesn't show confirmation that it worked
* Fixes issue #218 can't copy the memo text, including can't copy the reply-to address
* FIX: phantom seed when upgrading from old wallets
* FIX: Issue #221 tapping Back Up when creating a new wallet takes you back to the first screen
* FIX: Issue #222

## 0.3.0 build 66
This build has serious changes and improvements on seed management. TEST upgrades thoroughly


