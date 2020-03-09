//
//  ZcashSendButton.swift
//  wallet
//
//  Created by Francisco Gindre on 1/9/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashSendButton: View {
    
    var minimumDuration: TimeInterval = 5
    var longPressCancelled: () -> Void
    var longPressSucceded: () -> Void
    var longPressStarted: (() -> Void)?
    
    let innerCircleScale: CGFloat = 0.8
    var completionStrokeWidth: CGFloat = 16.0
    @State var startAngle: Double = 270
    @State var endAngle: Double = 270
    
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
                
                
                Text("Press and hold\nto send ZEC")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: geometry.size.width, idealWidth: geometry.size.width, maxWidth: geometry.size.width, minHeight: geometry.size.height, idealHeight: geometry.size.height, maxHeight: geometry.size.height, alignment: .center)
                    .onLongPressGesture(minimumDuration: 5, maximumDistance: 10, pressing: { (isPressing) in
                        if isPressing {
                            logger.event("is pressing")
                            self.longPressStarted?()
                        } else {
                            logger.event("not pressing anymore")
                            self.cancelAnimation()
                            self.longPressCancelled()
                        }
                    }, perform: {
                        self.longPressSucceded()
                    })
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

struct ZcashSendButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            ZcashSendButton(longPressCancelled: {}, longPressSucceded: {})
            
        }
    }
}
