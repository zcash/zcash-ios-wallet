//
//  ShareViewingKey.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 2/19/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit
struct ShareViewingKey: View {
    
    @State var viewingKey: String = try! DerivationTool.default.deriveViewingKeys(seed: MnemonicSeedProvider.default.toSeed(mnemonic: try! SeedManager.default.exportPhrase()), numberOfAccounts: 1).first!
    @State var birthday: BlockHeight = try! SeedManager.default.exportBirthday()
    
    @State var copyItemModel: PasteboardItemModel?
    @State var isShareModalDisplayed = false
    @State var isShareAddressShown = false
    var qrImage: Image {
        if let img = QRCodeGenerator.generate(from: self.viewingKey) {
            return Image(img, scale: 1, label: Text(String(format:NSLocalizedString("QR Code for %@", comment: ""),"viewing key") ))
        } else {
            return Image("zebra_profile")
        }
    }
 
    let qrSize: CGFloat = 200
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                QRCodeContainer(qrImage: qrImage,
                                badge: Image("QR-zcashlogo"))
                    .frame(width: qrSize, height: qrSize, alignment: .center)
                    .layoutPriority(1)
                    
                
                Button(action: {
                    PasteboardAlertHelper.shared.copyToPasteBoard(value: self.viewingKey, notify: "Viewing Key Copied!".localized())
                    logger.debug("viewing key copied to clipboard")
             
                }) {
                    VStack{
                        Text(viewingKey)
                            .foregroundColor(.white)
                        Text("Key's Birthday: \(birthday)")
                            .foregroundColor(.zGray3)
                    }
                }.alert(item: self.$copyItemModel) { (p) -> Alert in
                    PasteboardAlertHelper.alert(for: p)
                }
                .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
                    self.copyItemModel = p
                }
                
                Spacer()
                
                Button(action: {
                    tracker.track(.tap(action: .receiveScan), properties: [:])
                    self.isShareAddressShown = true
                }) {
                    Text("Share Viewing Key")
                        .foregroundColor(Color.white)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 1)))
                        .frame(height: 58)
                    
                }
          

            }.padding(30)
                .sheet(isPresented: self.$isShareAddressShown) {
                    ShareSheet(activityItems: [self.viewingKey])
            }
        }
        .navigationBarTitle(Text("Your Viewing Key"))
    }
}

