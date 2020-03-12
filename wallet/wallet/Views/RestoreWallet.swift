//
//  RestoreWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import ZcashLightClientKit

struct RestoreWallet: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var seedPhrase: String = ""
    @State var walletBirthDay: String = ""
    var isValidBirthday: Bool {
        validateBirthday(walletBirthDay)
    }
    
    var isValidSeed: Bool {
        validateSeed(seedPhrase)
    }
    
    func validateBirthday(_ birthday: String) -> Bool {
        
        guard !birthday.isEmpty else {
            return true
        }
        
        guard let b = BlockHeight(birthday) else {
            return false
        }
        
        return b >= ZcashSDK.SAPLING_ACTIVATION_HEIGHT
    }
    
    func validateSeed(_ seed: String) -> Bool {
        MnemonicSeedProvider.default.isValid(mnemonic: seed)
    }
    
    func importBirthday() throws {
        let b = BlockHeight(self.walletBirthDay.trimmingCharacters(in: .whitespacesAndNewlines)) ?? ZcashSDK.SAPLING_ACTIVATION_HEIGHT
        try SeedManager.default.importBirthday(b)
    }
    
    func importSeed() throws {
        let trimmedSeedPhrase = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSeedPhrase.isEmpty, let seedBytes =
            MnemonicSeedProvider.default.toSeed(mnemonic: trimmedSeedPhrase) else { throw ZECCWalletEnvironment.WalletError.createFailed
        }
        
        try SeedManager.default.importSeed(seedBytes)
        try SeedManager.default.importPhrase(bip39: trimmedSeedPhrase)
    }
    
    var disableProceed: Bool {
        !isValidSeed || !isValidBirthday
    }
    
    @State var proceed: Bool = false
    var body: some View {
        ZStack {
            NavigationLink(destination: Home(amount: 0, verifiedBalance: appEnvironment.initializer.getBalance().asHumanReadableZecBalance()).environmentObject(appEnvironment), isActive: $proceed) {
                EmptyView()
            }
            
            ZcashBackground()
            
            VStack {
                Spacer()
                ZcashTextField(
                    title: "Enter your Seed Phrase",
                    subtitleView: AnyView(
                        Text.subtitle(text: "Make sure nobody is watching you!")
                    ),
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $seedPhrase,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                Spacer()
                ZcashTextField(
                    title: "Wallet Birthday height",
                    subtitleView: AnyView(
                        Text.subtitle(text: "If you don't know it, leave it blank. First Sync will take longer.")
                    ),
                    keyboardType: UIKeyboardType.decimalPad,
                    binding: $walletBirthDay,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                Spacer()
                Button(action: {
                    do {
                        try self.importSeed()
                        try self.importBirthday()
                        try self.appEnvironment.initialize()
                    } catch {
                        logger.error("\(error)")
                        return
                    }
                    
                    self.proceed = true
                }) {
                    ZcashButton(color: .black, fill: .zAmberGradient1, text: "Proceed")
                }
                .disabled(disableProceed)
                .opacity(disableProceed ? 0.4 : 1.0)
                .frame(height: 58)
                
                Spacer()
            }.padding()
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

struct RestoreWallet_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWallet().environmentObject(ZECCWalletEnvironment.shared)
    }
}
