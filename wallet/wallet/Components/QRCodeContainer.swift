//
//  QRCodeContainer.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct QRCodeContainer: View {
    var qrImage: Image
    var badge: Image
    var body: some View {
        ZStack {
            qrImage
                .resizable()
                .aspectRatio(contentMode: .fit)
            badge
            .resizable()
            .frame(width: 64, height: 64)
        }
    }
}

struct QRCodeContainer_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack {
            ZcashBackground()
            QRCodeContainer(qrImage: Image("QrCode"),
                            badge: Image("QR-zcashlogo"))
            .frame(width: 285, height: 285)
            
        }
    }
}
