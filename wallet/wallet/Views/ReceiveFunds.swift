//
//  ReceiveFunds.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ReceiveFunds<Dismissal: Identifiable>: View {
    
    let shieldedAddress: String
    let transparentAddress: String
    @Binding var isShown: Dismissal?
    @State var selectedTab: Int = 0
    var body: some View {
        NavigationView {
            
            ZStack {
                ZcashBackground()
                VStack(alignment: .center, spacing: 10, content: {
                    TabSelector(tabs: [
                        (Text("Shielded")
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, idealHeight: 48)
                         ,.zYellow),
                        (Text("Transparent")
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, minHeight: 48, idealHeight: 48)
                         ,.zTransparentBlue)
                            
                    ], selectedTabIndex: $selectedTab)
                    .padding([.horizontal], 16)
                   
                    if selectedTab == 0 {
                        DisplayAddress(address: shieldedAddress,
                                       title: "address_shielded".localized(),
                                       badge: Image("QR-zcashlogo"),
                                       accessoryContent: { EmptyView() })
                            .animation(.easeInOut)
                    } else {
                        DisplayAddress(address: transparentAddress,
                                       title: "address_transparent".localized(),
                                       chips: 2,
                                       badge: Image("t-zcash-badge"),
                                       accessoryContent: {
                                         Text("""
                                            This address is for receiving only.
                                            Any funds received will be auto-shielded.
                                            """)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                       })
                            .animation(.easeInOut)
                    }
                    
                })
            }
            .onAppear {
                tracker.track(.screen(screen: .receive), properties: [:])
            }
            .navigationBarTitle(Text("receive_title"),
                                displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing: ZcashCloseButton(action: {
                tracker.track(.tap(action: .receiveBack), properties: [:])
                self.isShown = nil
                }).frame(width: 30, height: 30))
        }
    }
}
//
//struct ReceiveFunds_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ReceiveFunds(address: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6", isShown:  .constant(true))
//                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
//                .previewDisplayName("iPhone 8")
//            
//            ReceiveFunds(address: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6", isShown:  .constant(true))
//                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
//                .previewDisplayName("iPhone 11 Pro Max")
//        }
//    }
//}
