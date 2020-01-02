//
//  ZcashLogo.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashLogo: View {

    
   
    
    var fillGradient: LinearGradient {
        LinearGradient(gradient: Gradient(
                                    colors: [Color.zAmberGradient1,
                                             Color.zAmberGradient2]
                                    ),
                       startPoint: UnitPoint(x: 0.5, y: 0),
                       endPoint: UnitPoint(x: 0.5, y: 1.0))
        
    }
    
    var body: some View {
        ZStack {
            
            Ring()
            .stroke(lineWidth: 20)
                .fill(fillGradient)
                .frame(width: 280, height: 280, alignment: .center)
                .padding(20)
            VStack (alignment: .center) {
                ZcashSymbol()
                    .fill(fillGradient)
                    .frame(width: 200, height: 200, alignment: .center)
                .padding(20)
                
            }
            
                
        }
    }
}

struct ZcashLogo_Previews: PreviewProvider {
    static var previews: some View {
        ZcashLogo()
    }
}
