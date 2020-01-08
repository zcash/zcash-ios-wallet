//
//  Colors.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    /// \#FFBC00 Color(red: 1, green: 185.0/255.0, blue: 0)
    static let zYellow = Color(red: 1, green: 185.0/255.0, blue: 0)
    
    /// \#FFD000 Color(red: 1, red: 0.82, blue: 0)
    static let zAmberGradient0 = Color(red: 1.0, green: 0.82, blue: 0.0)
    /// Color(red: 1.0, green:0.64, blue:0.0)
    static let zAmberGradient1 = Color(red: 1.0, green:0.64, blue:0.0)
    
    /// \#FF9400
    static let zAmberGradient2 = Color(red: 1.0, green:0.74, blue:0.0)
    
    ///  \#FFB300 Color(red: 1.0, green:0.70, blue:0.0)
    static let zAmberGradient3 = Color(red: 1.0, green:0.70, blue:0.0)
    
    /// \#FF9400 Color(red: 1.0, green: 0.58, blue: 0.0)
    static let zAmberGradient4 = Color(red: 1.0, green: 0.58, blue: 0.0)
    
    static let zBlackGradient1 = Color(red:0.16, green:0.16, blue:0.17)
    
    static let zBlackGradient2 = Color.black
    
    /// \#282828 Color(red: 0.17, green: 0.17, blue: 0.17)
    static let zGray = Color(red:0.16, green:0.16, blue:0.16)
    
    /// Color(red: 151/255, green: 151/255, blue: 151/255)
    static let zLightGray = Color(red: 151/255, green: 151/255, blue: 151/255)
    
    /// \#D8D8D8 Color(red:0.85, green:0.85, blue:0.85)
    static let zLightGray2 = Color(red:0.85, green:0.85, blue:0.85)
    
    /// Color(red: 0.17, green: 0.17, blue: 0.17)
    static let zDarkGray1 = Color(red: 0.17, green: 0.17, blue: 0.17)
    
    /// \#171717 Color(red: 0.09, green: 0.09, blue: 0.09)
    static let zDarkGray2 = Color(red: 0.09, green: 0.09, blue: 0.09)
    
    /// \#656565 Color(red: 0.4, green: 0.4, blue: 0.4)
    static let zGray2 = Color(red: 0.4, green: 0.4, blue: 0.4)
    
    /// # Card colors
    
    
    /// \#FF4CA6 red:1.00, green:0.30, blue:0.65
    static let zNegativeZecAmount = Color(red:1.0, green:0.30, blue:0.65)
    
    /// \#2AFF6E Color(red:0.16, green:1.00, blue:0.43)
    static let zPositiveZecAmount = Color(red:0.16, green:1.00, blue:0.43)
    
    
    /// # Paid Card gradient
    
    /// \#FFB322 Color(red:1.0, green:0.70, blue:0.13)
    static let zPaidCardGradient1 = Color(red:1.0, green:0.70, blue:0.13)
    
    /// \# FF4242 Color(red:1.0, green:0.26, blue:0.26)
    static let zPaidCardGradient2 = Color(red:1.0, green:0.26, blue:0.26)
    
}

extension Gradient {
    static let paidCard = Gradient(colors: [Color.zPaidCardGradient1, .zPaidCardGradient2])
}


extension UIColor {
    static let zLightGray = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    static let zDarkGray = UIColor(red: 0.02, green: 0.02, blue: 0.02, alpha: 1)
}
