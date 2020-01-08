//
//  ScanAddress.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ScanAddress: View {
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack {
                Text("Scan Recipient Address")
                    .frame(height: 64)
                    
                .foregroundColor(.white)
                .edgesIgnoringSafeArea([.all])
                Spacer()
            }
            
            Text("Scan Address")
                .foregroundColor(.white)
        }
    }
}

struct ScanAddress_Previews: PreviewProvider {
    static var previews: some View {
        ScanAddress()
    }
}
