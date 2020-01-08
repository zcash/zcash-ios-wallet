//
//  ZcashBackground.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashBackground: View {
    var color1: Color = Color.zBlackGradient1
    var color2: Color = Color.zBlackGradient2
    
    var showGradient = true
    func radialGradient(radius: CGFloat, center: UnitPoint = .center) -> some View {
        let colors = Gradient(colors: [color1, color2])
        
        let conic = RadialGradient(gradient: colors, center: center, startRadius: 0, endRadius: radius)
        return conic
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                Color.black
                
                if self.showGradient {
                    self.radialGradient(
                        radius: max(geometry.size.width, geometry.size.height),
                        center: UnitPoint(
                            x: 0.5,
                            y: 0.3
                        )
                    )
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct Background_Previews: PreviewProvider {
    static var previews: some View {
        ZcashBackground()
    }
}
