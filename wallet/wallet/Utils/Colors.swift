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
    /// \#FFB900 Color(red: 1, green: 185.0/255.0, blue: 0)
    static let zYellow = Color(red: 1, green: 185.0/255.0, blue: 0)
    
    /// Transparent things blue
    /// \#4A90E2 Color(red:24/255, red: 144/255, blue: 226/255)
    static let zTransparentBlue = Color(red: 24/255, green: 144/255, blue: 226/255)
    
    /// \#FFD000 Color(red: 1, red: 0.82, blue: 0)
    static let zAmberGradient0 = Color(red: 1.0, green: 0.82, blue: 0.0)
    /// Color(red: 1.0, green:0.64, blue:0.0)
    static let zAmberGradient1 = Color(red: 1.0, green:0.64, blue:0.0)
    
    /// \#FF9400
    static let zAmberGradient2 = Color(red: 1.0, green:0.74, blue:0.0)
    
    ///  \#FFB300 Color(red: 1.0, green:0.70, blue:0.0)
    static let zAmberGradient3 = Color(red: 1.0, green:0.70, blue:0.0)
    
    /// \#FF9300 Color(red: 1.0, green: 0.58, blue: 0.0)
    static let zAmberGradient4 = Color(red: 1.0, green: 0.58, blue: 0.0)
    
    static let zBlackGradient1 = Color(red:0.16, green:0.16, blue:0.17)
    
    static let zBlackGradient2 = Color.black
    
    /// \#282828 Color(red: 0.17, green: 0.17, blue: 0.17)
    static let zGray = Color(red:0.16, green:0.16, blue:0.16)
    
    /// \#4A4A4A Color(red: 74/255, green: 74/255, blue: 74/255)
    static let zGray2 = Color(red: 74/255, green: 74/255, blue: 74/255)
    
    /// \#656565 Color(red: 0.4, green: 0.4, blue: 0.4)
    static let zGray3 = Color(red: 0.4, green: 0.4, blue: 0.4)
    
    /// Color(red: 151/255, green: 151/255, blue: 151/255)
    static let zLightGray = Color(red: 151/255, green: 151/255, blue: 151/255)
    
    /// \#D8D8D8 Color(red:0.85, green:0.85, blue:0.85)
    static let zLightGray2 = Color(red:0.85, green:0.85, blue:0.85)
    
    /// Color(red: 0.17, green: 0.17, blue: 0.17)
    static let zDarkGray1 = Color(red: 0.17, green: 0.17, blue: 0.17)
    
    /// \#171717 Color(red: 0.09, green: 0.09, blue: 0.09)
    static let zDarkGray2 = Color(red: 0.09, green: 0.09, blue: 0.09)
    
    /// \#A7A7A7 Color(red: 0.65, green: 0.65, blue: 0.65)
    static let zDarkGray3 = Color(red: 0.65, green: 0.65, blue: 0.65)
    
    /// \#F7F7F7
    static let zDudeItsAlmostWhite = Color(red: 247/255, green: 247/255, blue: 247/255)
   
    
    /// # Card colors
    
    
    /// \#FF4CA6 red:1.00, green:0.30, blue:0.65
    static let zNegativeZecAmount = Color(red:1.0, green:0.30, blue:0.65)
    
    /// \#2AFF6E Color(red:0.16, green:1.00, blue:0.43)
    static let zPositiveZecAmount = Color(red:0.16, green:1.00, blue:0.43)
    
    
    /// # Paid Card gradient
    
    /// \#FFB322 Color(red:1.0, green:0.70, blue:0.13)
    static let zPendingCardGradient1 = Color(red:1.0, green:0.70, blue:0.13)
    
    /// \# FF4242 Color(red:1.0, green:0.26, blue:0.26)
    static let zPendingCardGradient2 = Color(red:1.0, green:0.26, blue:0.26)
    
    // \# FFD649 Color(red: 1, green: 214/255, blue: 73/255)
    static let zPaidCardGradient1 = Color(red: 1, green: 214/255, blue: 73/255)
    
    // \# FFA918 Color(red: 1, green: 169/255, blue: 24/255)
    static let zPaidCardGradient2 = Color(red: 1, green: 169/255, blue: 24/255)
    
    // \#D2D2D2 Color(red: 210/255, green: 210/255, blue: 210/255)
    static let zFailedCardGradient1 = Color(red: 210/255, green: 210/255, blue: 210/255)
    
    // \#838383 Color(red: 131/255, green: 131/255, blue: 131/255)
    static let zFailedCardGradient2 = Color(red: 131/255, green: 131/255, blue: 131/255)
    
    // \#7DFF81 Color(red:125/255, green: 1, blue: 129/255)
    static let zReceivedCardGradient1 = Color(red:125/255, green: 1, blue: 129/255)
    
    // \#42EEFF Color(red:66/255, green: 238/255, blue: 1)
    static let zReceivedCardGradient2 = Color(red:66/255, green: 238/255, blue: 1)
    
    /// #Hold Button
    /// \#979797  Color(red:0.59, green:0.59, blue:0.59)
    static let zHoldButtonGray = Color(red:0.59, green:0.59, blue:0.59)
    
    
    /// Amount Breakdown Gray
    
    static let zLeastSignificantAmountGray = Color(red: 119/255, green: 119/255, blue: 119/255)
    
    static let zBalanceBreakdownGradient1 = Color(red: 42/255, green: 41/255, blue: 51/255)
    
    static let zBalanceBreakdownGradient2 = Color(red: 45/255, green: 45/255, blue: 51/255)
    
    static let zBalanceBreakdownItem0 = Color(red: 44/255, green: 44/255, blue: 52/255)
    static let zBalanceBreakdownItem1 = Color(red: 134/255, green: 134/255, blue: 134/255, opacity: 0.081)
    static let zBalanceBreakdownItem2 = Color(red: 0, green: 0, blue: 0, opacity: 0.081)
    
}

extension Gradient {
    
    static let paidCard = Gradient(colors: [Color.zPaidCardGradient1, .zPaidCardGradient2])
    
    static let failedCard = Gradient(colors: [Color.zFailedCardGradient1, .zFailedCardGradient2])
    
    static let receivedCard = Gradient(colors: [Color.zReceivedCardGradient1, .zReceivedCardGradient2])
}


extension UIColor {
    static let zLightGray = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    static let zDarkGray = UIColor(red: 0.02, green: 0.02, blue: 0.02, alpha: 1)
}
