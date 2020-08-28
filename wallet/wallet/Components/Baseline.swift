//
//  Baseline.swift
//  wallet
//
//  Created by Francisco Gindre on 7/29/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct Topline: Shape {
    func path(in rect: CGRect) -> Path {
        Path {
            path  in
            path.move(
                to: CGPoint(
                    x: rect.origin.x,
                    y: rect.minY
                )
            )
            path.addLine(
                to: CGPoint(
                    x: rect.maxX,
                    y: rect.minY
                )
            )
        }
    }
}
struct Baseline: Shape {
    func path(in rect: CGRect) -> Path {
        Path {
            path  in
            path.move(
                to: CGPoint(
                    x: rect.origin.x,
                    y: rect.maxY
                )
            )
            path.addLine(
                to: CGPoint(
                    x: rect.maxX,
                    y:  rect.maxY
                )
            )
        }
    }
    
}
