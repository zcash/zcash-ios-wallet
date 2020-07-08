//
//  ShareScreen.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ShareScreen: View {
    var body: some View {
        
        ZStack {
            ZcashBackground()
            Text("Share Screen".localized())
                .foregroundColor(.white)
        }
        
    }
}

struct ShareScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShareScreen()
    }
}
