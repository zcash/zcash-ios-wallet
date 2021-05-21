//
//  ZcashLogo.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashLogo<S: ShapeStyle>: View {

    var fillStyle: S
    
    
    init(fillStyle: S) {
        self.fillStyle = fillStyle
    }
    
    var body: some View {
        ZStack {
            Ring()
            .stroke(lineWidth: 14)
                .fill(fillStyle)
                .frame(width: 167, height: 167, alignment: .center)
                .padding(20)
            VStack (alignment: .center) {
                ZcashSymbol()
                    .fill(fillStyle)
                    .frame(width: 100, height: 105, alignment: .center)
                
            }
        }
    }
}

extension LinearGradient {
    static var amberGradient: LinearGradient {
        LinearGradient(gradient: Gradient(
                                    colors: [Color.zAmberGradient1,
                                             Color.zAmberGradient2]
                                    ),
                       startPoint: UnitPoint(x: 0.5, y: 0),
                       endPoint: UnitPoint(x: 0.5, y: 1.0))
    }
}
