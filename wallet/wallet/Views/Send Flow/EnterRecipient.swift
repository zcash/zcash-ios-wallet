//
//  EnterRecipient.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct EnterRecipient: View {
    
    var amount: Double
    var verifiedBalance: Double
    
    @State var text: String = ""
    
    var availableBalance: Bool {
        verifiedBalance > 0
    }
    
    var amountSubtitle: String {
        if availableBalance, let balance = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) {
            return "You Have \(balance) sendable ZEC"
        } else {
            return "You don't have any sendable ZEC yet"
        }
    }
    
    var validAddress: Bool {
        text.count > 0
    }
    
    var validForm: Bool {
        availableBalance && validAddress
    }
    
    var body: some View {
        ZStack {
            Background()
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) {
                    Spacer().frame(width: 48)
                    Text("Sending")
                        .frame(height: 64)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                }
                .edgesIgnoringSafeArea([.top])
                
                Spacer().frame(height: 96)
                ZcashTextField(title: "To", subtitle: "Enter a shielded Zcash address", binding: $text, action: {
                    print("qr pressed")
                }, accessoryIcon: Image("QRCodeIcon")
                .renderingMode(.original))
                
                ZcashTextField(title: "Amount", subtitle: "You have 23.451234 sendable ZEC", binding: $text, action: {
                    print("qr pressed")
                }, accessoryIcon: Image("QRCodeIcon")
                .renderingMode(.original))
                
                ActionableMessage(message: "Zcash address in buffer", actionText: "Paste", action: {})
                Spacer()
                
            }.padding([.horizontal], 24)
            
        }.navigationBarItems(trailing: Image("infobutton"))
    }
    
    init(amount: Double, verifiedBalance: Double) {
        
        self.amount = amount
        self.verifiedBalance = verifiedBalance
    }
}

struct EnterRecipient_Previews: PreviewProvider {
    static var previews: some View {
        EnterRecipient(amount: 1.2345, verifiedBalance: 23.451234)
    }
}
