//
//  RestoreWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
final class RestoreWalletViewModel: ObservableObject {
    @Published var seedPhrase: String = ""
   
    
    var isValidSeed: Bool {
        seedPhrase.count > 0 /// TODO: improve validation
    }
    
    func importSeed() {
        try? SeedManager.default.importSeed(seedPhrase)
    }
}

struct RestoreWallet: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @ObservedObject var viewModel = RestoreWalletViewModel()
    @State var proceed: Bool = false
    var body: some View {
        ZStack {
            NavigationLink(destination: Home(amount: 0, verifiedBalance: appEnvironment.initializer.getBalance().asHumanReadableZecBalance()), isActive: $proceed) {
                EmptyView()
            }
            
            ZcashBackground()
            
            VStack {
                Spacer()
                ZcashTextField(title: "Enter your Seed Phrase", subtitle: "Make sure nobody is watching you!", binding: $viewModel.seedPhrase)
                Spacer()
                Button(action: {
                    self.viewModel.importSeed()
                }) {
                    ZcashButton(color: .black, fill: .zAmberGradient1, text: "Proceed")
                    
                }
                .disabled(!viewModel.isValidSeed)
                .frame(height: 58)
                
                Spacer()
            }.padding()
        }
    }
}

struct RestoreWallet_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWallet().environmentObject(try! ZECCWalletEnvironment())
    }
}
