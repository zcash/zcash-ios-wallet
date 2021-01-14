//
//  TxDetailWrapper.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 1/6/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI


struct TxDetailsWrapper: View {
    @State var row: DetailModel
    @Binding var isActive: DetailModel?
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 0) {
                TransactionDetails(detail: row)
                    .zcashNavigationBar(leadingItem: {
                       EmptyView()
                    }, headerItem: {
                        HStack{
                            Text("Transaction Details")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(alignment: Alignment.center)
                        }
                    }, trailingItem: {
                        ZcashCloseButton(action: {
                            self.isActive = nil
                            }).frame(width: 30, height: 30)
                    })
            }
            .padding(.top, 20)
        }
    }
}
