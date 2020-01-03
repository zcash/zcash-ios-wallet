//
//  Home.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct Home: View {
    
    @Binding var sendZecAmount: Double
    init(amount: Binding<Double> = .constant(Double.zero)) {
        _sendZecAmount = amount
        
    }
    
    
    var body: some View {
        
        ZStack {
            Background(showGradient: $sendZecAmount.wrappedValue > 0)
            
            VStack(alignment: .center, spacing: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom) {
                        Image("QRCodeIcon")
                            .renderingMode(.original)
                            .scaleEffect(0.5)
                        Spacer()
                    }
                }
                
                SendZecView(zatoshi: $sendZecAmount)
                    .opacity($sendZecAmount.wrappedValue > 0 ? 1.0 : 0.3)
                
                if $sendZecAmount.wrappedValue > 0 {
                    BalanceDetail(availableZec: $sendZecAmount.wrappedValue, status: .available)
                } else {
                    Spacer()
                    ActionableMessage(message: "No Balance", actionText: "Fund Now", action: {})
                        .padding()
                }
                Spacer()
                KeyPad()
                    .opacity($sendZecAmount.wrappedValue > 0 ? 1.0 : 0.3)
                    .disabled($sendZecAmount.wrappedValue <= 0)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Syncing")
                        
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.zAmberGradient2, lineWidth: 4)
                    )
                }
                
                Spacer()
                
                Button(action: {})  {
                    HStack(alignment: .center, spacing: 10) {
                        Image("wallet_details_icon")
                        Text("Wallet Details")
                            .font(.headline)
                    }.accentColor(Color.zLightGray)
                }
                Spacer()
                
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(amount: .constant(2))
    }
}
