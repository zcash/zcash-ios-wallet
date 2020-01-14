//
//  ZcashCloseButton.swift
//  wallet
//
//  Created by Francisco Gindre on 1/10/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashCloseButton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image("close")
        }
    }
}
