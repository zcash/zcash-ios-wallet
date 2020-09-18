//
//  ReceiveFunds.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ReceiveFunds: View {
    
    let address: String
    @Binding var isShown: Bool
    var body: some View {
        NavigationView {
            
            ZStack {
                ZcashBackground()
                DisplayAddress(address: address)
            }
            .onAppear {
                tracker.track(.screen(screen: .receive), properties: [:])
            }
            .navigationBarTitle(Text("receive_title"),
                                displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing: ZcashCloseButton(action: {
                tracker.track(.tap(action: .receiveBack), properties: [:])
                self.isShown = false
                }).frame(width: 30, height: 30))
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
