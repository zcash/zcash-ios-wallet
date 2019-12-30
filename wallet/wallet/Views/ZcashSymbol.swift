//
//  ZcashSymbol.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashSymbol: Shape {
    
    static let ratio: CGFloat = 0.56
    func path(in rect: CGRect) -> Path {
        Path { path in
            
            let width = rect.height * Self.ratio
            let origin = CGPoint(x: abs(rect.width - width)/2, y: 0)
            let height = rect.height
            let middle = width / 2
            let yOffset = height / 10
            let bottomHeight = height - yOffset
            
            path.move(
                to: CGPoint(
                    x: origin.x,
                    y: yOffset
                )
            )
            
            path.addLine(
                to: CGPoint(
                    x: middle,
                    y: yOffset
                )
            )
            
            path.addLine(to:
                CGPoint(
                    x: middle,
                    y: origin.y
                )
            )
            
            path.move(
                to: CGPoint(
                    x: middle,
                    y: yOffset
                )
            )
            path.addLine(
                to: CGPoint(
                    x: width,
                    y: yOffset
                )
            )
            path.move(
                to: CGPoint(
                    x: width ,
                    y: yOffset
                )
            )
            path.addLine(
                to: CGPoint(
                    x: origin.x,
                    y: bottomHeight
                )
            )
            path.addLine(
                to: CGPoint(
                    x: middle,
                    y: bottomHeight
                )
            )
            path.addLine(
                to: CGPoint(
                    x: middle,
                    y: height
                )
            )
            path.move(to: CGPoint(
                x: middle,
                y: bottomHeight
                )
            )
            path.addLine(
                to: CGPoint(
                    x: width,
                    y: bottomHeight
                )
            )
        }
    }
}
