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
            MnemonicSeedProvider.default.toSeed(mnemonic: trimmedSeedPhrase) else { throw WalletError.createFailed
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
            NavigationLink(destination: LazyView(Home(amount: 0, verifiedBalance: self.appEnvironment.initializer.getBalance().asHumanReadableZecBalance()).environmentObject(self.appEnvironment)), isActive: $proceed) {
                EmptyView()
            }
            
            ZcashBackground()
            
            VStack {
                Spacer()
                ZcashTextField(
                    title: "Enter your Seed Phrase".localized(),
                    subtitleView: AnyView(
                        Text.subtitle(text: "Make sure nobody is watching you!".localized())
                    ),
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $seedPhrase,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                Spacer()
                ZcashTextField(
                    title: "Wallet Birthday height".localized(),
                    subtitleView: AnyView(
                        Text.subtitle(text: "If you don't know it, leave it blank. First Sync will take longer.".localized())
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
                    tracker.track(.tap(action: .walletImport), properties: [:])
                    self.proceed = true
                }) {
                    Text("Proceed")
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                }
                .disabled(disableProceed)
                .opacity(disableProceed ? 0.4 : 1.0)
                .frame(height: 58)
            }
            .padding([.horizontal,.bottom], 30)
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear {
            tracker.track(.screen(screen: .restore), properties: [:])
        }
        .navigationBarTitle("Restore from Seed Phrase", displayMode: .inline)
        .navigationBarHidden(false)
    }
}

struct RestoreWallet_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWallet().environmentObject(ZECCWalletEnvironment.shared)
    }
}
