//
//  ZcasMemoTextField.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI



struct ZcashMemoTextView: View {
    @Binding var text: String
    @Binding var showSendingAddress: Bool
    var fromAddress: String = ""
    @State var textHeight: CGFloat = 174
    var charLimit: Int = 255
    var body: some View {
        ZStack{
            ZStack(alignment: .bottom){
                VStack(alignment: .trailing, spacing: 0) {
                    TextView(placeholder: "Add Memo Here".localized(),
                             text: $text,
                             minHeight: self.textHeight,
                             limit: charLimit,
                             calculatedHeight: $textHeight)
                        .foregroundColor(.white)
                        .frame(height: textHeight)
                        .padding(4)
                        .multilineTextAlignment(.leading)
                    Text("%@ chars".localized(with: "\($text.wrappedValue.count)/\(charLimit)"))
                        .font(.footnote)
                        .foregroundColor(Color.zLightGray2)
                        .opacity(0.4)
                        .padding(4)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Add a memo here".localized())
                            .foregroundColor(Color.zLightGray2)
                            .opacity(self.text.isEmpty ? 0.6 : 0)
                        
                        Spacer()
                        }.offset(x: 0, y: -20)
                    .padding([.leading], 8)
                        .layoutPriority(1)
                    Spacer()
                     if $showSendingAddress.wrappedValue {
                        Text("from %@".localized(with: "\(fromAddress)" ))
                            .foregroundColor(Color.zLightGray2)
                            .font(.caption)
                            .opacity(0.6)
                            .padding([.horizontal, .bottom], 10)
                     }
                }
                .frame(height: textHeight)
                .edgesIgnoringSafeArea(.all)
            }
        }
        .background(Color.zDarkGray2)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.zGray, lineWidth: 1)
        )
            .padding()
        
        
    }
}

struct ZcasMemoTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center) {
                ZcashMemoTextView(text: .constant(""), showSendingAddress: .constant(false),fromAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6")
                    
                    .padding([.leading, .trailing], 24)
            }
        }
    }
}
