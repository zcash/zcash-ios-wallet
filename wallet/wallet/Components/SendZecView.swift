//
//  SendZecView.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct SendZecView: View {
    
    @Binding var zatoshi: String
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
//            ZcashSymbol()
//                .fill(Color.zLightGray)
//                .frame(width: 25, height: 25)
//                .offset(x: 0, y: -10)
//
            Text("$")
            .lineLimit(1)
            .foregroundColor(.white)
            .font(
                .custom("Zboto", size: 72)
            )
            Text(self.$zatoshi.wrappedValue)
                .lineLimit(1)
                .foregroundColor(.white)
                .font(
                    .custom("Zboto", size: 72)
                )
        }
    }
}

struct SendZecView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            SendZecView(zatoshi: .constant("12.345"))
        }
    }
}
