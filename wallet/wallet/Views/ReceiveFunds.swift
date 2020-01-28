//
//  ReceiveFunds.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ReceiveFunds: View {
    
    init(address: String) {
        self.address = address
    }
    
    @State var isCopyAlertShown = false
    @State var isShareModalDisplayed = false
    
    var address: String
    let qrSize: CGFloat = 285
    var body: some View {
        NavigationView {
            ZStack {
                ZcashBackground()
                VStack(alignment: .center, spacing: 40) {
                    Spacer()
                    QRCodeContainer(qrImage: Image("QrCode"))
                        .frame(width: qrSize, height: qrSize)
                    
                    Button(action: {
                        UIPasteboard.general.string = self.address
                        print("address copied to clipboard")
                        self.isCopyAlertShown = true
                    }) {
                        VStack(alignment: .center, spacing: 0) {
                            Text("Your Address")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .regular, design: .default))
                            Text(address)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(width: qrSize)
                                .padding([.leading, .trailing], 16)
                            
                        }
                    }.alert(isPresented: self.$isCopyAlertShown) {
                        Alert(title: Text(""),
                              message: Text("Address Copied to clipboard!"),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Spacer()
                    NavigationLink(destination: ScanAddress()) {
                        ZcashButton(color: Color.black, fill: Color.zYellow, text: "Scan Recipient Addresss")
                            .frame(height: 58)
                            .padding([.leading, .trailing], 30)
                        
                    }
                    Spacer()
                }
                
            }.navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarHidden(true)
        }
    }
}

struct ReceiveFunds_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReceiveFunds(address: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6")
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            ReceiveFunds(address: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6")
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
        }
    }
}
