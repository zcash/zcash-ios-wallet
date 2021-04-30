//
//  ReceiveFunds.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit
struct ReceiveFunds: View {
    
    let unifiedAddress: UnifiedAddress
    @Environment(\.presentationMode) var presentationMode
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
                        DisplayAddress(address: unifiedAddress.zAddress,
                                       title: "address_shielded".localized(),
                                       badge: Image("QR-zcashlogo"),
                                       accessoryContent: { EmptyView() })
                    } else {
                        DisplayAddress(address: unifiedAddress.tAddress,
                                       title: "address_transparent".localized(),
                                       chips: 2,
                                       badge: Image("t-zcash-badge"),
                                       accessoryContent: {
                                        VStack(alignment: .leading) {
                                             Text("This address is for receiving only.")
                                                .lineLimit(nil)
                                                .foregroundColor(.white)
                                                .font(.system(size: 14))
                                            Text("Any funds received will be auto-shielded.")
                                               .lineLimit(nil)
                                               .foregroundColor(.white)
                                               .font(.system(size: 14))
                                        }
                                       })
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
                presentationMode.wrappedValue.dismiss()
                }).frame(width: 30, height: 30))
        }
    }
}
