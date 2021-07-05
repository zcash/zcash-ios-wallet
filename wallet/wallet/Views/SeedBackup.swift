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
    @State var error: WalletError?
    @State var showError = false
    @State var copyItemModel: PasteboardItemModel?
    @State var proceedsToHome = false
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    
    var seed: String {
        var phrase = ""
        do {
            phrase = try SeedManager.default.exportPhrase()
            
        } catch {
            return "there was an error retrieving your seed: \(error)"
        }
        
        do {
            try MnemonicSeedProvider.default.isValid(mnemonic: phrase)
            return phrase
        } catch {
            return  """
                    the stored seed is not valid.
                    Error: \(error)
                    """
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
        \("title_backupseed".localized()):
        \(seed)
        
        \("seed_birthday".localized()):
        \(birthday)
        """
    }
    
    var gridView: AnyView {
        do {
            
            let seedPhrase = try SeedManager.default.exportPhrase()
            
            try MnemonicSeedProvider.default.isValid(mnemonic: seedPhrase)
            
            let words = try MnemonicSeedProvider.default.asWords(mnemonic: seedPhrase)
            
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
            self.showError = true
        }
        return AnyView(EmptyView())
    }
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 16) {
                
                Text("title_backupseed".localized())
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(alignment: .leading)
                Text("copy_backupseed".localized())
                    .font(.footnote)
                    .foregroundColor(Color.zLightGray)
                    .multilineTextAlignment(.leading)
                    .frame(alignment: .leading)
                    .padding()

                gridView
                Text("\("seed_birthday".localized()): \(birthday)")
                    .foregroundColor(Color.zLightGray)
                    .font(.footnote)
                    .frame(alignment: .leading)
             
                Button(action: {
                    tracker.track(.tap(action: .copyAddress), properties: [:])
                    do {
                        try MnemonicSeedProvider.default.isValid(mnemonic: seed)
                    } catch {
                        self.error = ZECCWalletEnvironment.mapError(error: error)
                        self.showError = true
                        return
                    }
                    PasteboardAlertHelper.shared.copyToPasteBoard(value: self.copyText, notify: "send_onclipboard".localized())
                }) {
                    Text("button_copytoclipboard")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(height: buttonHeight)
                        .opacity(0.4)
                }
                if proceedsToHome {
                    NavigationLink(destination:
                                    LazyView(
                                        Home(viewModel: ModelFlyWeight.shared.modelBy(defaultValue: HomeViewModel()))
                                    )) {
                        Text("button_done")
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
        .alert(isPresented: self.$showError) {
            Alert(title: Text("Problem Retrieving your seed"),
                  message: Text("we are unable to display your seed phrase. close the app and retry this operation"),
                  dismissButton: .default(Text("button_close")))
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
