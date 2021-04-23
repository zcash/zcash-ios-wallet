//
//  DisplayAddress.swift
//  wallet
//
//  Created by Francisco Gindre on 7/24/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct DisplayAddress: View {
    
    @State var copyItemModel: PasteboardItemModel?
    @State var isShareModalDisplayed = false
    @State var isShareAddressShown = false
    var qrImage: Image {
        if let img = QRCodeGenerator.generate(from: self.address) {
            return Image(img, scale: 1, label: Text(String(format:NSLocalizedString("QR Code for %@", comment: ""),"\(self.address)") ))
        } else {
            return Image("zebra_profile")
        }
    }
    var badge: Image
    var caption: String
    var address: String
    var chips: [String]
    let qrSize: CGFloat = 200
    
    init(address: String, caption: String, chips: Int = 8, badge: Image) {
        self.address = address
        self.caption = caption
        self.chips = address.slice(into: chips)
        self.badge = badge
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            QRCodeContainer(qrImage: qrImage,
                            badge: badge)
                .frame(width: qrSize, height: qrSize, alignment: .center)
                .layoutPriority(1)
            
            Text(caption)
                .foregroundColor(.white)
                .font(.system(size: 18))
                
            
            Button(action: {
                PasteboardAlertHelper.shared.copyToPasteBoard(value: self.address, notify: "feedback_addresscopied".localized())
                logger.debug("address copied to clipboard")
         
                tracker.track(.tap(action: .copyAddress), properties: [:])
            }) {
                VStack {
                    if chips.count <= 2 {
                        
                        ForEach(0 ..< chips.count) { i in
                            AddressFragment(number: i + 1, word: self.chips[i])
                                .frame(height: 24)
                        }
                        
                    } else {
                        ForEach(stride(from: 0, through: chips.count - 1, by: 2).map({ i in i}), id: \.self) { i in
                            HStack {
                                AddressFragment(number: i + 1, word: self.chips[i])
                                    .frame(height: 24)
                                AddressFragment(number: i + 2, word: self.chips[i+1])
                                    .frame(height: 24)
                            }
                        }
                    }
                    
                }.padding([.horizontal], 15)
                .frame(minHeight: 96)
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
                Text("button_share_address")
                    .foregroundColor(Color.white)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 1)))
                    .frame(height: 58)
                
            }
      

        }.padding(30)
            .sheet(isPresented: self.$isShareAddressShown) {
                ShareSheet(activityItems: [self.address])
        }
    }
}
//
//struct DisplayAddress_Previews: PreviewProvider {
//    static var previews: some View {
//        DisplayAddress(address: "zs1t2scx025jsy04mqyc4x0fsyspxe86gf3t6gyfhh9qdzq2a789sc2eccslflawf2kpuvxcqfjsef")
//    }
//}
