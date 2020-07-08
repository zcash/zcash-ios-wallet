//
//  WalletDetailsHeader.swift
//  wallet
//
//  Created by Francisco Gindre on 1/21/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct WalletDetailsHeader: View {
    var zAddress: String
    var body: some View {
        ZStack {
            Color.zDarkGray2
            VStack(alignment: .leading) {
                Text("Your Wallet History".localized())
                .lineLimit(1)
                    .font(.title)
                    .foregroundColor(.white)
                HStack {
                    Text("Shielded address:".localized())
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.white)

                    Text(zAddress)
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundColor(Color.zYellow)
                }
                
            }
        }
    }
}

struct WalletDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            WalletDetailsHeader(zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6")
        }.previewLayout(.fixed(width: 300, height: 100
            ))
        
    }
}
