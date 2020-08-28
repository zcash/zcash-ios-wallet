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
    var hideNavBar = true
    @State var copyItemModel: PasteboardItemModel?
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
        \("Seed:".localized())
        \(seed)
        
        \("Wallet Birthday:".localized())
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
            let message = "error retrieving seed"
            logger.error("\(message): \(error)")
            tracker.track(.error(severity: .critical), properties: [
                ErrorSeverity.messageKey : message,
                ErrorSeverity.underlyingError : "\(error)"
            ])
        }
        return AnyView(EmptyView())
    }
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 16) {
                
                Text("Your Backup Seed".localized())
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(alignment: .leading)
                Text("Please back them up wisely!\nWe recommend a paper backup and a password vault".localized())
                    .font(.footnote)
                    .foregroundColor(Color.zLightGray)
                    .multilineTextAlignment(.leading)
                    .frame(alignment: .leading)
                    .padding()

                gridView
                Text("\("Wallet Birthday:".localized()) \(birthday)")
                    .foregroundColor(Color.zLightGray)
                    .font(.footnote)
                    .frame(alignment: .leading)
             
                Button(action: {
                    tracker.track(.tap(action: .copyAddress), properties: [:])
                    PasteboardAlertHelper.shared.copyToPasteBoard(value: self.copyText, notify: "Copied to clipboard!")
                }) {
                    Text("Copy to clipboard".localized())
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(height: buttonHeight)
                        .opacity(0.4)
                }
                if proceedsToHome {
                    NavigationLink(destination:  Home(amount: 0, verifiedBalance: appEnvironment.initializer.getBalance().asHumanReadableZecBalance()).environmentObject(appEnvironment)) {
                        Text("I'm all set!".localized())
                            .foregroundColor(.black)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                            .frame(height: buttonHeight)
                    }
                    
                }
                
            }.padding([.horizontal, .bottom], 24)
                .alert(item: self.$copyItemModel) { (p) -> Alert in
                    PasteboardAlertHelper.alert(for: p)
            }
        }
        .onAppear {
            tracker.track(.screen(screen: .backup), properties: [:])
        }
        .navigationBarTitle("",displayMode: .inline)
        .navigationBarHidden(hideNavBar)
    }
}

struct SeedBackup_Previews: PreviewProvider {
    static var previews: some View {
        SeedBackup().environmentObject(ZECCWalletEnvironment.shared)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension String {
    func slice(into pieces: Int) -> [String] {
        guard pieces > 0 else { return [] }
        let chunkSize = Int(ceilf(Float(self.count) / Float(pieces)))
        return chunked(intoAtMost: chunkSize)
    }
    func chunked(intoAtMost size: Int) -> [String] {
        return stride(from: 0, to: self.count, by: size).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start ..< end])
        }
    }
}
