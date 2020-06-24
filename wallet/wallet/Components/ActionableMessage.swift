//
//  ActionableMessage.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ActionableMessage: View {
    var message: String
    var actionText: String? = nil
    var action: (() -> Void)? = nil
    let cornerRadius: CGFloat =  5
    
    var actionView: some View {
        if let action = self.action, let text = actionText {
            return AnyView(
                Button(action: action) {
                    Text(text)
                        .foregroundColor(Color.zAmberGradient2)
                }
            )
        } else {
            return AnyView (
                EmptyView()
            )
        }
    }
    var body: some View {
        
        HStack {
            Text(message)
            .foregroundColor(.white)
            Spacer()
            actionView
            
        }
        .padding()
        .cornerRadius(cornerRadius)
        .background(Color.zDarkGray2)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.zGray, lineWidth: 1)
        )
    }
}

struct ActionableMessage_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            ActionableMessage(message: "Zcash address in buffer!".localized(), actionText: "Paste".localized(), action: {})
            .padding()
            
        }
    }
}
