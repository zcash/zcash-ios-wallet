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
final class RestoreWalletViewModel: ObservableObject {
    var seedPhrase: String = ""
    var walletBirthDay: String = ""
    
    func isValidBirthday(_ birthday: String) -> Bool {
        
        guard !birthday.isEmpty else {
            return true
        }
        
        guard let b = BlockHeight(birthday) else {
            return false
        }
        
        return b >= ZcashSDK.SAPLING_ACTIVATION_HEIGHT
    }
    
    
    func isValidSeed(_ seed: String) -> Bool {
        seed.lengthOfBytes(using: .utf8) >= 32
    }
    func importBirthday() throws {
        let b = BlockHeight(self.walletBirthDay) ?? ZcashSDK.SAPLING_ACTIVATION_HEIGHT
        try SeedManager.default.importBirthday(b)
    }
    func importSeed() throws {
        try SeedManager.default.importSeed(seedPhrase)
    }
    
}

struct RestoreWallet: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @ObservedObject var viewModel = RestoreWalletViewModel()
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
                    binding: $viewModel.seedPhrase
                )
                Spacer()
                ZcashTextField(
                                   title: "Wallet Birthday height",
                                   subtitleView: AnyView(
                                       Text.subtitle(text: "If you don't know it, leave it blank. First Sync will take longer.")
                                       ),
                                   keyboardType: UIKeyboardType.decimalPad,
                                   binding: $viewModel.walletBirthDay
                               )
                Spacer()
                Button(action: {
                    do {
                        try self.viewModel.importSeed()
                        try self.viewModel.importBirthday()
                        try self.appEnvironment.initialize()
                    } catch {
                        print("Error \(error)")
                        return
                    }
                    
                    self.proceed = true
                }) {
                    ZcashButton(color: .black, fill: .zAmberGradient1, text: "Proceed")
                }
                .disabled(viewModel.isValidSeed(viewModel.seedPhrase) && viewModel.isValidBirthday(viewModel.walletBirthDay))
                .opacity(viewModel.isValidSeed(viewModel.seedPhrase) && viewModel.isValidBirthday(viewModel.walletBirthDay) ? 1.0 : 0.4)
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
        RestoreWallet().environmentObject(try! ZECCWalletEnvironment())
    }
}
