//
//  SquareToggleStyle.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 7/29/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct SquareToggleStyle: ToggleStyle {
    @Binding var isHighlighted: Bool
    
    var activeColor = Color.zAmberGradient2
    var inactiveColor = Color.zGray2
    func makeBody(configuration: Configuration) -> some View {

        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                ZStack {
                    Rectangle()
                        .stroke(inactiveColor, lineWidth: isHighlighted ? 0 : 0.5)
                        .background(isHighlighted ? activeColor : Color.clear)
                    Image("checkmark")
                        .colorMultiply(.black)
                        .opacity(isHighlighted ? 1 : 0)
                    
                    
                }
                .frame(width: 16, height: 16)
                
                configuration.label
                    .font(.footnote)
                    .foregroundColor(.white)
            }
        }
        
        
        
    }
    
}




struct SquareToggleStyle_Previews: PreviewProvider {
    @State static var isOn: Bool = true
    static var previews: some View {
        ZStack {
            ZcashBackground()
            Toggle(isOn: $isOn) {
                Text("includes reply to")
            }
            .toggleStyle(SquareToggleStyle(isHighlighted: $isOn))
            //            .frame(width: 16, height: 16)
            
        }
    }
}
