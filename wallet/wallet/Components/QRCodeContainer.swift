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
    var body: some View {
        ZStack {
            ZcashButtonBackground(cornerTrim: 15)
                .fill(Color.zDarkGray1)
            qrImage.padding()
        }
    }
}

struct QRCodeContainer_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack {
            Background()
            QRCodeContainer(qrImage: Image("QrCode"))
            .frame(width: 285, height: 285)
            
        }
    }
}
