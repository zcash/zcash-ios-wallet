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
            ZcashButtonBackground()
                .fill(self.fill)
            ZcashButtonBackground()
                .stroke(self.color, lineWidth: 1.0)
                
            Text(text)
            .foregroundColor(color)
                .font(.headline)
        }
    }
}

private struct ZcashButtonBackground: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        Path {
            path in
            
            let lipLength = min(rect.size.height, rect.size.width) / 4.0
            
            
            path.move(
                to: CGPoint(
                    x: lipLength,
                    y: rect.origin.y
                )
            )
            
            // top border
            path.addLine(
                to: CGPoint(
                    x: rect.width - lipLength,
                    y: rect.origin.y
                )
            )
            
            // top right lip
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: lipLength
                )
            )
            
            // right border
            
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: rect.height - lipLength
                )
            )
            
            // bottom right lip
            path.addLine(
                to: CGPoint(
                    x: rect.width - lipLength,
                    y: rect.height
                )
            )
            
            // bottom border
            
            path.addLine(
                to: CGPoint(
                    x: lipLength,
                    y: rect.height
                )
            )
            
            // bottom left lip
            
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x,
                    y: rect.height - lipLength
                )
            )
            
            // left border
            
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x,
                    y: lipLength
                )
            )
            
            // top left lip
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x + lipLength,
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
