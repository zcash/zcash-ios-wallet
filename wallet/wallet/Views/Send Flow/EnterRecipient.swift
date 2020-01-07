//
//  EnterRecipient.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct EnterRecipient: View {
    
    var verifiedBalance: Double
    var amount: Double
    @State var zAddress: String = ""
    @State var amountText: String = ""
    var availableBalance: Bool {
        verifiedBalance > 0
    }
    
    var amountSubtitle: String {
        if availableBalance, let balance = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: verifiedBalance)) {
            return "You Have \(balance) sendable ZEC"
        } else {
            return "You don't have any sendable ZEC yet"
        }
    }
    
    var validAddress: Bool {
        zAddress.count > 0
    }
    
    var validForm: Bool {
        availableBalance && validAddress
    }
    
    var body: some View {
        ZStack {
            Background()
           
            VStack(alignment: .leading, spacing: 20) {

                Spacer().frame(height: 96)
                ZcashTextField(
                    title: "To",
                    subtitle: "Enter a shielded Zcash address",
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $zAddress,
                    action: {
                        print("qr pressed")
                },
                    accessoryIcon: Image("QRCodeIcon")
                        .renderingMode(.original)
                )
                
                ZcashTextField(
                    title: "Amount",
                    subtitle: "You have 23.451234 sendable ZEC",
                    keyboardType: UIKeyboardType.decimalPad,
                    binding: $amountText
                )
                
                
                ActionableMessage(message: "Zcash address in buffer", actionText: "Paste", action: {})
                Spacer()
                Button(action:{}) {
                    ZcashButton(color: Color.black, fill: Color.zYellow, text: "Next")
                        .frame(height: 58)
                        .padding([.leading, .trailing], 40)
                }
                    .opacity(validForm ? 1.0 : 0.3 ) // validate this
                    .disabled(!validForm)
                Spacer()
                
            }.padding([.horizontal], 24)
            
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }.navigationBarItems(trailing: Image("infobutton"))
    }
    
    init(amount: Double, verifiedBalance: Double) {
        
        self.amount = amount
        self.verifiedBalance = verifiedBalance
        self.amountText = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) ?? ""
    }
}

struct EnterRecipient_Previews: PreviewProvider {
    static var previews: some View {
        EnterRecipient(amount: 1.2345, verifiedBalance: 23.451234)
    }
}
