//
//  ZcasMemoTextField.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashMemoTextView: View {
    @State var text: String = ""
    var charLimit: Int = 255
    var body: some View {
        ZStack{
            VStack(alignment: .trailing, spacing: 0) {
                TextField("",text: $text)
                    
                    .frame(height: 174)
                    .padding(4)
                    .multilineTextAlignment(.leading)
                Text("\($text.wrappedValue.count)/\(charLimit) chars")
                    .font(.footnote)
                    .foregroundColor(Color.zLightGray2)
                    .opacity(0.4)
                    .padding(4)
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Add a memo here")
                    .foregroundColor(Color.zLightGray2)
                    .opacity(0.6)
                    Spacer()
                }
                .padding([.leading], 8)
                Spacer()
            }
            .frame(height: 174)
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
            Background()
            VStack(alignment: .center) {
                ZcashMemoTextView()
                    
                    .padding([.leading, .trailing], 24)
            }
        }
    }
}
