//
//  ZcashLogo.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashLogo: View {

    
   var radialGradient: some View {
          let colors = Gradient(colors: [Color.zGray, .black])
          let conic = RadialGradient(gradient: colors, center: .center, startRadius: 50, endRadius: 200)
          return Circle()
              .fill(conic)
              .frame(width: 400, height: 400)
      }
    
    var body: some View {
        ZStack {
            radialGradient
            Image("zcash-icon-gradient")
        }
    }
}

struct ZcashLogo_Previews: PreviewProvider {
    static var previews: some View {
        ZcashLogo()
    }
}
