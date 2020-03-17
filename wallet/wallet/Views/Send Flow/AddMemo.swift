//
//  AddMemo.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct AddMemo: View {
    
    @EnvironmentObject var flow: SendFlowEnvironment
    @State var isShown = false
    
    let buttonHeight: CGFloat = 58
    let buttonPadding: CGFloat = 30
    var legend: String {
        flow.includeSendingAddress ? "Your address is shielded from the public,\n but will be available to the receipient via the memo field." : "Your transaction is shielded and your address is unavailable to receipent."
    }
    var isMemoEmpty: Bool {
        flow.memo.count == 0 && !flow.includeSendingAddress
    }
    
    var sendText: String {
        !isMemoEmpty ? "Discard and Send" : "Send Now"
    }
    var body: some View {
        
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 15) {
                Spacer()
                ZcashMemoTextView(text: $flow.memo, showSendingAddress: $flow.includeSendingAddress,
                                  fromAddress: ZECCWalletEnvironment.shared.initializer.getAddress() ?? "",
                    charLimit: SendFlowEnvironment.maxMemoLength )
                HStack {
                    ZcashCheckCircle(isChecked: $flow.includeSendingAddress)
                    .onTapGesture {
                        self.flow.includeSendingAddress.toggle()
                    }
                    Text("Include your sending address in a memo")
                        .foregroundColor(Color.zLightGray2)
                }
                
                Text(legend)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.zLightGray2)
                    .opacity(0.4)
                    .padding([.horizontal], 30)
                    .frame(minHeight: 64)
                    .layoutPriority(0.5)
                Spacer()
                Button(action: {
                    self.flow.includesMemo = true
                    self.isShown = true
                }) {
                    Text("Add Memo")
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: ZcashFillStyle.solid(color: Color.zYellow)))
                        .frame(height: self.buttonHeight)
                        .padding([.leading, .trailing], self.buttonPadding)
                        .opacity( isMemoEmpty ? 0.3 : 1 )
                    
                }.disabled(isMemoEmpty)
                
                NavigationLink(
                    destination: HoldToSend().environmentObject(flow)
                    ) {
                        EmptyView()
                }.isDetailLink(false)
                NavigationLink(
                    destination: HoldToSend().environmentObject(flow),
                    isActive: self.$isShown
                ) {
                    EmptyView()
                }.isDetailLink(false)
                Button(action: {
                    self.flow.includesMemo = false
                    self.isShown = true
                }) {
                    Text(sendText)
                        .foregroundColor(.white)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 2)))
                    .frame(height: self.buttonHeight)
                    .padding([.leading, .trailing], self.buttonPadding)
                }
               
                Spacer()
                
            }
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }
        .navigationBarTitle("Add Memo (optional)", displayMode: .inline)
    }
}

struct AddMemo_Previews: PreviewProvider {
    static var previews: some View {
        AddMemo()
    }
}
