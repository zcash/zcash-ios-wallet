//
//  UIKit+Extensions.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

func _zECCWalletNavigationBarLookTweaks() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.largeTitleTextAttributes = [
        .font : UIFont.systemFont(ofSize: 20),
        NSAttributedString.Key.foregroundColor : UIColor.white
    ]
    
    appearance.titleTextAttributes = [
        .font : UIFont.systemFont(ofSize: 20),
        NSAttributedString.Key.foregroundColor : UIColor.white
    ]
    
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().tintColor = .white
    
    let clearView = UIView()
    clearView.backgroundColor = UIColor.clear
    UITableViewCell.appearance().selectedBackgroundView = clearView
    UITableView.appearance().backgroundColor = UIColor.clear
}
