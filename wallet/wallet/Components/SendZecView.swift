//
//  SendZecView.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct SendZecView: View {
    
    @Binding var zatoshi: Double
    
    func format(amount: Double) ->  String {
        if amount <= 0 {
            return "0"
        }
        
        return NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) ?? "ERROR"
    }
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            ZcashSymbol()
                .fill(Color.zLightGray)
                .frame(width: 25, height: 25)
                .offset(x: 0, y: -10)
            
            Text(self.format(amount: self.$zatoshi.wrappedValue))
                .lineLimit(1)
                .foregroundColor(.white)
                .font(
                    Font.system(
                        size: 48,
                        weight: .medium,
                        design: .default
                    )
            )
        }
    }
}

struct SendZecView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            SendZecView(zatoshi: .constant(12.345))
        }
    }
}
