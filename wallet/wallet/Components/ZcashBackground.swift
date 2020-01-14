//
//  ZcashBackground.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashBackground: View {
    var backgroundColor: Color = .black
    var colors: [Color] = [Color.zBlackGradient1, Color.zBlackGradient2]
    
    var showGradient = true
    func radialGradient(radius: CGFloat, center: UnitPoint = .center) -> some View {
        let gradientColors = Gradient(colors: colors)
        
        let conic = RadialGradient(gradient: gradientColors, center: center, startRadius: 0, endRadius: radius)
        return conic
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                self.backgroundColor
                
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

extension ZcashBackground {
    static var amberGradient: ZcashBackground {
        ZcashBackground(colors: [Color.zAmberGradient0, .zAmberGradient3, .zAmberGradient4])
    }
    static var amberSplashScreen: ZcashBackground {
        ZcashBackground(colors: [Color.zAmberGradient0, .zAmberGradient3, .zAmberGradient4])
    }
}
struct Background_Previews: PreviewProvider {
    static var previews: some View {
        ZcashBackground.amberGradient
        
    }
}

