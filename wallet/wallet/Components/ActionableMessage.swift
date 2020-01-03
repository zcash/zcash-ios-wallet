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
    var actionText: String
    var action: () -> Void
    let cornerRadius: CGFloat =  5
    var body: some View {
        
        HStack {
            Text(message)
            .foregroundColor(.white)
            Spacer()
            Button(action: action) {
                Text(actionText)
                    .foregroundColor(Color.zAmberGradient2)
            }
            
        }
        .padding()
        .cornerRadius(cornerRadius)
        .background(Color.zDarkGray)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.zLightGray, lineWidth: 1)
        )
        
    
            
    }
}

struct ActionableMessage_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Background()
            ActionableMessage(message: "Zcash address in buffer!", actionText: "Paste", action: {})
            .padding()
            
        }
    }
}
