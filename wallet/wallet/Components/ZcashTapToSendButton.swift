//
//  ZcashTapToSendButton.swift
//  wallet
//
//  Created by Francisco Gindre on 3/18/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//


import SwiftUI

struct ZcashTapToSendButton: View {
    
    let innerCircleScale: CGFloat = 0.8
    var completionStrokeWidth: CGFloat = 16.0
    @State var startAngle: CGFloat = 270
    @State var endAngle: CGFloat = 270
    
    var body: some View {
        
        ZStack (alignment: .center) {
            GeometryReader { geometry in
                
                Circle()
                    .size(geometry.size)
                    .fill(Color.black)
                    .shadow(color: .zLightGray, radius: 2, x: 0, y: 2)
                Circle()
                    .size(geometry.size)
                    .fill(Color.zHoldButtonGray)
                    .scaleEffect(self.innerCircleScale)
                    .opacity(0.35)
                Wedge(
                    startAngle: self.startAngle,
                    endAngle: self.endAngle,
                    clockwise: false
                )
                    
                    .stroke(Color.zAmberGradient2, lineWidth: self.completionStrokeWidth)
                    .animation(.easeIn(duration: 5))
                
                
                Text("Tap\nto send ZEC".localized())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: geometry.size.width, idealWidth: geometry.size.width, maxWidth: geometry.size.width, minHeight: geometry.size.height, idealHeight: geometry.size.height, maxHeight: geometry.size.height, alignment: .center)
                    
            }
        }
        .frame(
            width: 167,
            height: 167,
            alignment: .center
        )
    }
    
    func startAnimation() {
        self.startAngle = 270
        self.endAngle = 180
        
    }
    
    func cancelAnimation() {
        self.startAngle = 270
        self.endAngle = 270
    }
}

struct ZcashTapToSendButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            ZcashTapToSendButton()
            
        }
    }
}
