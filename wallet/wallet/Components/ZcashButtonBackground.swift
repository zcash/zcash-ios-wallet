//
//  ZcashButtonBackground.swift
//  wallet
//
//  Created by Francisco Gindre on 3/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

enum ZcashFillStyle {
    case gradient(gradient: LinearGradient)
    case solid(color: Color)
    case outline(color: Color, lineWidth: CGFloat)
    
    func fill<S: Shape>(_ s: S) -> AnyView {
        switch self {
        case .gradient(let g):
            return AnyView (s.fill(g))
        case .solid(let color):
            return AnyView(s.fill(color))
        case .outline(color: let color, lineWidth: let lineWidth):
            return AnyView(
                s.stroke(color, lineWidth: lineWidth)
            )
        }
    }
}

struct ZcashButtonBackground: ViewModifier {
    
    enum BackgroundShape {
        case chamfered(fillStyle: ZcashFillStyle)
        case rounded(fillStyle: ZcashFillStyle)
        case roundedCorners(fillStyle: ZcashFillStyle)
    }
    
    var buttonShape: BackgroundShape
    init(buttonShape: BackgroundShape) {
        self.buttonShape = buttonShape
    }
    
    func backgroundWith(geometry: GeometryProxy, backgroundShape: BackgroundShape) -> AnyView {
        
        switch backgroundShape {
        case .chamfered(let fillStyle):
            
            return AnyView (
                fillStyle.fill( ZcashChamferedButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0))
            )
        case .rounded(let fillStyle):
            return AnyView(
                fillStyle.fill(
                    ZcashRoundedButtonBackground()
                )
            )
        case .roundedCorners(let fillStyle):
            return AnyView(
                fillStyle.fill(
                    ZcashRoundCorneredButtonBackground()
                )
            )
        
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            GeometryReader { geometry in
                self.backgroundWith(geometry: geometry, backgroundShape: self.buttonShape)
            }
            content
            
        }
    }
}

extension Text  {
    func zcashButtonBackground(shape: ZcashButtonBackground.BackgroundShape) -> some View {
        self.modifier(ZcashButtonBackground(buttonShape: shape))
    }
}


struct ZcashButtonBackground_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            
            VStack {
                
                Text("Create new Wallet")
                    .font(.body)
                    .foregroundColor(Color.black)
                    .modifier(ZcashButtonBackground(buttonShape: .chamfered(fillStyle: .solid(color: Color.zYellow))))
                    .frame(height: 50)
                Text("Create new Wallet")
                                   .font(.body)
                                   .foregroundColor(Color.zYellow)
                    .modifier(ZcashButtonBackground(buttonShape: .chamfered(fillStyle: .outline(color: Color.zYellow, lineWidth: 2))))
                                   .frame(height: 50)
                Text("button_done")
                    .font(.body)
                    .foregroundColor(Color.black)
                    .modifier(ZcashButtonBackground(buttonShape: .chamfered(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient))))
                    .frame(height: 50)
                Text("button_backup")
                .font(.body)
                .foregroundColor(Color.white)
                    .modifier(ZcashButtonBackground(buttonShape: .chamfered(fillStyle: .outline(color: Color.white, lineWidth: 1))))
                .frame(height: 50)
                
                Text("button_done")
                .font(.body)
                .foregroundColor(Color.black)
                .modifier(ZcashButtonBackground(buttonShape: .rounded(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient))))
                .frame(height: 50)
                
                Text("button_done")
                .font(.body)
                .foregroundColor(Color.black)
                .modifier(ZcashButtonBackground(buttonShape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient))))
                .frame(height: 50)
                Text("button_done")
                    .font(.body)
                    .foregroundColor(Color.white)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 1)))
                    .frame(height: 50)
            }.padding()
        }
    }
}

extension LinearGradient {
    static var zButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.zAmberGradient3, Color.zAmberGradient4]),
            startPoint: UnitPoint(x: 0, y: 0.5),
            endPoint: UnitPoint(x: 1, y: 0.5))
    }
}
