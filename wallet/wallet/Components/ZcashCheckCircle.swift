//
//  ZcashCheckCircle.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashCheckCircle: View {
    @State var isChecked: Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center){
                
                self.ring(size: geometry.size, color: Color.zGray2, lineWidth: 2)
                self.ring(size: CGSize(width: geometry.size.width , height: geometry.size.height), color: Color.zAmberGradient2, lineWidth: 4)
                    .scaleEffect(0.9, anchor: UnitPoint(x: 0.5,y: 0.5))
                    .opacity(self.$isChecked.wrappedValue ? 1 : 0)
                Image("checkmark")
                    .opacity(self.$isChecked.wrappedValue ? 1 : 0)
            
            }
        }.frame(width: 30, height: 30, alignment: .center)
            .onTapGesture {
                self.isChecked.toggle()
        }
    }
    
    func ring(size: CGSize, color: Color, lineWidth: CGFloat) -> some View {
        Path { path in
            path.addArc(
                center: CGPoint(
                    x: size.width / 2,
                    y: size.height / 2
                    ),
                radius: size.width / 2,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 360),
                clockwise: true)
        }.stroke(color,lineWidth: lineWidth)
    }
    
    
}

struct ZcashCheckCircle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Background()
            ZcashCheckCircle()
        }
    }
}
