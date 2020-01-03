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
            Background()
            Text("Scan Address")
                .foregroundColor(.white)
            }
        .navigationBarTitle("Scan Recipient Address", displayMode: .inline)
    }
}

struct ScanAddress_Previews: PreviewProvider {
    static var previews: some View {
        ScanAddress()
    }
}
