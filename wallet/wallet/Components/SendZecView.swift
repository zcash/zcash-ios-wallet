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
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                
                ZcashSymbol()
                    .fill(Color.zLightGray)
                    .frame(width: 25, height: 25)
                    .offset(x: 0, y: -10)
                
                Text(self.format(amount: self.$zatoshi.wrappedValue))
                    .foregroundColor(.white)
                    .font(
                        Font.system(
                            size: 72,
                            weight: .medium,
                            design: .default
                        )
                )
            }
        }
        
    }
}

struct SendZecView_Previews: PreviewProvider {
    static var previews: some View {
        SendZecView(zatoshi: .constant(12.345))
    }
}
