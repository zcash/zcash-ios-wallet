//
//  Ring.swift
//  wallet
//
//  Created by Francisco Gindre on 1/1/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI

struct Ring: Shape {
    
    private var wedge: Wedge = Wedge(
                                startAngle: 0.0,
                                endAngle: 360,
                                clockwise: false
                                )
    
    func path(in rect: CGRect) -> Path {
        self.wedge.path(in: rect)
    }
}

struct Wedge: Shape {
    
    var startAngle: Double
    var endAngle: Double
    var clockwise: Bool = true
//
//    var animatableData: AnimatablePair<Double,Double> {
//        get { AnimatablePair(startAngle, endAngle) }
//        set {
//            startAngle = newValue.first
//            endAngle = newValue.second
//        }
//    }
    
    func path(in rect: CGRect) -> Path {
        Path() { path in
             path.addArc(
                           center: CGPoint(
                                x: rect.midX,
                                y: rect.midY
                            ),
                           radius: rect.width / 2 ,
                           startAngle: Angle(degrees: startAngle),
                           endAngle: Angle(degrees: endAngle),
                           clockwise: clockwise
                       )
        }
    }
}


