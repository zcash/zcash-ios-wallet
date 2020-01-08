//
//  AddMemo.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct AddMemo: View {
    
    @State var includeSendingAddress: Bool = false
    @State var memo: String = ""
    let buttonHeight: CGFloat = 58
    let buttonPadding: CGFloat = 30
    var legend: String {
        includeSendingAddress ? "Your address is shielded from the public,\n but will be available to the receipient via the memo field." : "Your transaction is shielded and your address is unavailable to receipent."
    }
    var body: some View {
        
        ZStack {
            Background()
            VStack(alignment: .center, spacing: 15) {
                Spacer()
                ZcashMemoTextView(text: $memo)
                HStack {
                    ZcashCheckCircle(isChecked: $includeSendingAddress)
                    Text("Include your sending address in a memo")
                        .foregroundColor(Color.zLightGray2)
                }
                
                Text(legend)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
//                    .frame(minHeight: 0, maxHeight: 200)
                    .foregroundColor(Color.zLightGray2)
                    .opacity(0.4)
                    .padding([.horizontal], 30)
                    .layoutPriority(0.5)
                Spacer()
                
                ZcashButton(color: Color.black, fill: Color.zYellow, text: "Add Memo")
                    .frame(height: self.buttonHeight)
                    .padding([.leading, .trailing], self.buttonPadding)
                
                ZcashButton(color: .white, fill: .clear, text: "Send Now")
                .frame(height: self.buttonHeight)
                .padding([.leading, .trailing], self.buttonPadding)
                Spacer()
                
            }
        }
    }
}

struct AddMemo_Previews: PreviewProvider {
    static var previews: some View {
        AddMemo()
    }
}
