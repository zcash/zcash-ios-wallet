//
//  EnterRecipient.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine

struct EnterRecipient: View {
    
    @EnvironmentObject var flow: SendFlowEnvironment
    
    var availableBalance: Bool {
        flow.verifiedBalance > 0
    }
    
    var addressSubtitle: String {
        let environment = ZECCWalletEnvironment.shared
        guard !flow.address.isEmpty else {
           return "Enter a shielded Zcash address"
        }
        
        if environment.initializer.isValidShieldedAddress(flow.address) {
            return "This is a valid shielded address!"
        } else {
            return "Invalid shielded address!"
        }
    }
    
    var amountSubtitle: String {
        if availableBalance, let balance = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: flow.verifiedBalance)) {
            return "You Have \(balance) sendable ZEC"
        } else {
            return "You don't have any sendable ZEC yet"
        }
    }
    
    var validAddress: Bool {
        ZECCWalletEnvironment.shared.initializer.isValidShieldedAddress(flow.address)
    }
    
    var validForm: Bool {
        availableBalance && validAddress
    }
    
    var addressInBuffer: AnyView {
        guard let clipboard = UIPasteboard.general.string,
            ZECCWalletEnvironment.shared.initializer.isValidShieldedAddress(clipboard),
            clipboard.shortZaddress != nil else {
                return AnyView(EmptyView())
        }
        
        return AnyView(
            ActionableMessage(message: "Zcash address in buffer", actionText: "Paste", action: { self.flow.address = clipboard })
                )
    }
    
    var body: some View {
        ZStack {
            ZcashBackground()
            
            VStack(alignment: .leading, spacing: 20) {
                
                Spacer().frame(height: 96)
                ZcashTextField(
                    title: "To",
                    subtitleView: AnyView(
                        Text.subtitle(text: addressSubtitle)
                        ),
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $flow.address,
                    action: {
                        self.flow.showScanView = true
                },
                    accessoryIcon: Image("QRCodeIcon")
                        .renderingMode(.original),
                    onEditingChanged: { _ in },
                    onCommit: { }
                ).sheet(isPresented: self.$flow.showScanView) {
                    ScanAddress(
                        scanViewModel: ScanAddressViewModel(
                            address: self.$flow.address,
                            shouldShow: self.$flow.showScanView
                        )   
                    ).environmentObject(ZECCWalletEnvironment.shared)
                }
                
                ZcashTextField(
                    title: "Amount",
                    subtitleView: AnyView(
                        Text.subtitle(text: "You have \(flow.verifiedBalance) sendable ZEC")
                    ),
                    keyboardType: UIKeyboardType.decimalPad,
                    binding: $flow.amount,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                
                
                addressInBuffer
                Spacer()
                NavigationLink(destination: AddMemo().environmentObject(flow)){
                    Text("Next")
                        .foregroundColor(.black)
                        .font(.body)
                        .zcashButtonBackground(shape: .rounded(fillStyle: .solid(color: Color.zYellow)))
                        .frame(height: 58)
                        
                }
                .isDetailLink(false)
                .opacity(validForm ? 1.0 : 0.3 ) // validate this
                .disabled(!validForm)
                
            }.padding([.horizontal,.bottom], 24)
            
        }
        .onAppear() {
            self.flow.clearMemo()
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}



struct EnterRecipient_Previews: PreviewProvider {
    static var previews: some View {
        EnterRecipient().environmentObject(SendFlowEnvironment(amount: 1.2345, verifiedBalance: 23.456, isActive: .constant(true)))
    }
}
