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
    @ObservedObject var viewModel = RestoreWalletViewModel()
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack {
                Spacer()
                ZcashTextField(title: "Enter your Seed Phrase", subtitle: nil, binding: $viewModel.seedPhrase)
                Spacer()
                Button(action: {
                    self.viewModel.importSeed()
                }) {
                    ZcashButton(color: .black, fill: .zAmberGradient1, text: "Proceed")
                    
                }
                .disabled(!viewModel.isValidSeed)
                .frame(height: 69)
                
                Spacer()
            }.padding()
        }
    }
}

struct RestoreWallet_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWallet()
    }
}
