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
    @State var includeSendingAddress: Bool = false
    let buttonHeight: CGFloat = 58
    let buttonPadding: CGFloat = 30
    var legend: String {
        includeSendingAddress ? "Your address is shielded from the public,\n but will be available to the receipient via the memo field." : "Your transaction is shielded and your address is unavailable to receipent."
    }
    var isMemoEmpty: Bool {
        flow.memo.count == 0 && !includeSendingAddress
    }
    
    var sendText: String {
        !isMemoEmpty ? "Discard and Send" : "Send Now"
    }
    var body: some View {
        
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 15) {
                Spacer()
                ZcashMemoTextView(text: $flow.memo)
                HStack {
                    ZcashCheckCircle(isChecked: $includeSendingAddress)
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
                
                NavigationLink(
                    destination: HoldToSend().environmentObject(flow)
                    ) {
                        ZcashButton(color: Color.black, fill: Color.zYellow, text: "Add Memo")
                        .frame(height: self.buttonHeight)
                        .padding([.leading, .trailing], self.buttonPadding)
                }.disabled(isMemoEmpty)
                    .opacity( isMemoEmpty ? 0.3 : 1 )
                NavigationLink(
                    destination: HoldToSend().environmentObject(flow),
                    isActive: self.$isShown
                ) {
                    EmptyView()
                }
                Button(action: {
                    self.flow.includesMemo = false
                    self.isShown = true
                }) {
                    ZcashButton(color: .white, fill: .clear, text: sendText)
                    .frame(height: self.buttonHeight)
                    .padding([.leading, .trailing], self.buttonPadding)
                }
               
                Spacer()
                
            }
        }
        .navigationBarTitle("Add Memo (optional)", displayMode: .inline)
        .navigationBarItems(trailing: Image("infobutton"))
    }
}

struct AddMemo_Previews: PreviewProvider {
    static var previews: some View {
        AddMemo()
    }
}
