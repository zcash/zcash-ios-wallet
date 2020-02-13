//
//  zECC+SwiftUI.swift
//  wallet
//
//  Created by Francisco Gindre on 2/12/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI

extension Text {
    static func subtitle(text: String) -> Text {
        Text(text)
        .foregroundColor(.zLightGray)
        .font(.footnote)
    }
}
