//
//  ZcashButton.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashButton: View {
    var color = Color.zYellow
    var fill = Color.black
    var text: String
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                ZcashButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0)
                .fill(self.fill)
                
                ZcashButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0)
                .stroke(self.color, lineWidth: 1.0)
            }
                Text(self.text)
                    .foregroundColor(self.color)
                .font(.body)
            
        }
    }
}

struct ZcashButtonBackground: Shape {
    var cornerTrim: CGFloat
    func path(in rect: CGRect) -> Path {
        
        Path {
            path in
            
            path.move(
                to: CGPoint(
                    x: cornerTrim,
                    y: rect.origin.y
                )
            )
            
            // top border
            path.addLine(
                to: CGPoint(
                    x: rect.width - cornerTrim,
                    y: rect.origin.y
                )
            )
            
            // top right lip
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: cornerTrim
                )
            )
            
            // right border
            
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: rect.height - cornerTrim
                )
            )
            
            // bottom right lip
            path.addLine(
                to: CGPoint(
                    x: rect.width - cornerTrim,
                    y: rect.height
                )
            )
            
            // bottom border
            
            path.addLine(
                to: CGPoint(
                    x: cornerTrim,
                    y: rect.height
                )
            )
            
            // bottom left lip
            
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x,
                    y: rect.height - cornerTrim
                )
            )
            
            // left border
            
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x,
                    y: cornerTrim
                )
            )
            
            // top left lip
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x + cornerTrim,
                    y: rect.origin.y
                )
            )
        }
    }
}

struct ZcashButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            ZcashButton(color: Color.zYellow, fill: Color.clear, text: "Create New Wallet")
                .frame(width: 300, height: 60)
        }
    }
}
