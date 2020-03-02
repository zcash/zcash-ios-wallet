//
//  SeedBackup.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct SeedBackup: View {
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 58
    
    @State var proceedsToHome = false
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    
    var seed: String {
        do {
            return try SeedManager.default.exportPhrase()
        } catch {
            return "there was an error retrieving your seed: \(error)"
        }
    }
    
    var birthday: String {
        do {
            return  String(try SeedManager.default.exportBirthday())
        } catch {
            return "There was an error retrieving your wallet birthday: \(error)"
        }
    }
    var copyText: String {
        """
        Seed:
        \(seed)
        
        Wallet Birthday:
        \(birthday)
        """
    }
    
    var gridView: AnyView {
        do {
            
            let seedPhrase = try SeedManager.default.exportPhrase()
            
            guard MnemonicSeedProvider.default.isValid(mnemonic: seedPhrase),
                let words = MnemonicSeedProvider.default.asWords(mnemonic: seedPhrase) else {
                    throw MnemonicError.invalidSeed
            }
            
            return AnyView(
                ZcashSeedPhraseGrid(words: words)
            )
            
        } catch {
            print("error retrieving seed: \(error)")
            
        }
        return AnyView(EmptyView())
    }
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 16) {
                
                Text("Your Backup Seed")
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(alignment: .leading)
                Text("Please back them up wisely!\nWe recommend a paper backup and a password vault")
                    .font(.footnote)
                    .foregroundColor(Color.zLightGray)
                    .multilineTextAlignment(.leading)
                    .frame(alignment: .leading)
                    .padding()
                
                
                gridView
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = self.copyText
                }) {
                    Text("Copy to clipboard")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .opacity(0.4)
                }
                if proceedsToHome {
                    NavigationLink(destination:  Home(amount: 0, verifiedBalance: appEnvironment.initializer.getBalance().asHumanReadableZecBalance()).environmentObject(appEnvironment)) {
                        ZcashButton(color: Color.black, fill: Color.zYellow, text: "I'm all set!")
                            .frame(height: buttonHeight)
                    }
                    .padding([.leading, .trailing], buttonPadding)
                }
                Spacer()
            }.padding(24)
        }
        
    }
}

struct SeedBackup_Previews: PreviewProvider {
    static var previews: some View {
        SeedBackup().environmentObject( ZECCWalletEnvironment.shared)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
