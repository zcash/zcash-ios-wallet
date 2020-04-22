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
        ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value > 0
    }
    
    var addressSubtitle: String {
        let environment = ZECCWalletEnvironment.shared
        guard !flow.address.isEmpty else {
           return "Enter a shielded Zcash address"
        }
        
        if environment.isValidAddress(flow.address) {
            return "This is a valid Zcash address!"
        } else {
            return "Invalid Zcash address!"
        }
    }
    
    func amountSubtitle(amount: String) ->  String {
        if availableBalance,
            let balance = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value)),
            let amountToSend = NumberFormatter.zecAmountFormatter.number(from: flow.amount)?.doubleValue {
            if ZECCWalletEnvironment.shared.sufficientFundsToSend(amount: amountToSend) {
                return "You Have \(balance) sendable ZEC"
            } else {
                return "\(balance) sendable ZEC. You don't have sufficient funds to cover the amount + Miner Fee of \(ZECCWalletEnvironment.minerFee) ZEC"
            }
        } else {
            return "You don't have any sendable ZEC yet"
        }
    }
    
    var validAddress: Bool {
        ZECCWalletEnvironment.shared.isValidAddress(flow.address)
    }
    
    var sufficientAmount: Bool {
        let amount = (flow.doubleAmount ??  0 )
         return amount > 0 && amount <= ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value
    }
    
    var validForm: Bool {
        availableBalance && validAddress && sufficientAmount
    }
    
    
    var addressInBuffer: AnyView {
        
        guard let clipboard = UIPasteboard.general.string,
            ZECCWalletEnvironment.shared.isValidAddress(clipboard),
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
                    NavigationView {
                        LazyView(
                            
                            ScanAddress(
                                  viewModel: ScanAddressViewModel(
                                    shouldShowSwitchButton: false,
                                    showCloseButton: true,
                                    address: self.$flow.address,
                                    shouldShow: self.$flow.showScanView),
                                  cameraAccess: CameraAccessHelper.authorizationStatus,
                                  isScanAddressShown: self.$flow.showScanView
                            ).environmentObject(ZECCWalletEnvironment.shared)
                           
                        )
                    }
                }
                
                ZcashTextField(
                    title: "Amount",
                    subtitleView: AnyView(
                        Text.subtitle(text: self.amountSubtitle(amount: flow.amount))
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


//
//struct EnterRecipient_Previews: PreviewProvider {
//    static var previews: some View {
//        EnterRecipient().environmentObject(SendFlowEnvironment(amount: 1.2345, verifiedBalance: 23.456, isActive: .constant(true)))
//    }
//}
