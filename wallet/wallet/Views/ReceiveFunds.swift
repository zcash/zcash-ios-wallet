//
//  ReceiveFunds.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ReceiveFunds: View {
    
    init(address: String, isShown: Binding<Bool>) {
        self.address = address
        self.chips = address.slice(into: 8)
        self._isShown = isShown
    }
    
    @State var isCopyAlertShown = false
    @State var isShareModalDisplayed = false
    @State var isScanAddressShown = false
    @Binding var isShown: Bool
    var qrImage: Image {
        if let img = QRCodeGenerator.generate(from: self.address) {
            return Image(img, scale: 1, label: Text("QR Code for \(self.address)"))
        } else {
            return Image("zebra_profile")
        }
    }
    var address: String
    var chips: [String]
    let qrSize: CGFloat = 285
    var body: some View {
        NavigationView {
            
            ZStack {
                ZcashBackground()
                VStack(alignment: .center) {
                    Spacer()
                    QRCodeContainer(qrImage: qrImage)
                        .frame(width: qrSize, height: qrSize, alignment: .center)
                        .layoutPriority(1)

                    Spacer()
                    Button(action: {
                        UIPasteboard.general.string = self.address
                        logger.debug("address copied to clipboard")
                        self.isCopyAlertShown = true
                    }) {
                        VStack {
                            
                            ForEach(stride(from: 0, through: chips.count - 1, by: 2).map({ i in i}), id: \.self) { i in
                                HStack {
                                    ZcashSeedWordPill(number: i + 1, word: self.chips[i])
                                        .frame(height: 24)
                                    ZcashSeedWordPill(number: i + 2, word: self.chips[i+1])
                                    .frame(height: 24)
                                }
                            }
                        }
                    }.alert(isPresented: self.$isCopyAlertShown) {
                        Alert(title: Text(""),
                              message: Text("Address Copied to clipboard!"),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Spacer()
                    NavigationLink(destination: ScanAddress(fromReceiveFunds: self.$isScanAddressShown) ,isActive: self.$isScanAddressShown ) {
                        EmptyView()
                    }
                    Button(action: {
                        self.isScanAddressShown = true
                    }) {
                        Text("Scan Recipient Address")
                        .foregroundColor(Color.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                            .frame(height: 58)
                            
                    }
                    Spacer()
                }.padding(30)
                
            }.navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing: ZcashCloseButton(action: {
                self.isShown = false
            }))
        }
    }
}

struct ReceiveFunds_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReceiveFunds(address: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6", isShown:  .constant(true))
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            ReceiveFunds(address: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6", isShown:  .constant(true))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
        }
    }
}
