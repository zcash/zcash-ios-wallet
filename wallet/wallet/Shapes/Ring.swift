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

    func path(in rect: CGRect) -> Path {
        
        Path() { circlePath in
            circlePath.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: rect.width / 2 ,
                startAngle: Angle(degrees: 0),endAngle: Angle(degrees: 360),
                clockwise: false
            )
        }
    }
}
