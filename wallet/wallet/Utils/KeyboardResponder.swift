//
//  KeyboardResponder.swift
//  wallet
//
//  Created by Francisco Gindre on 7/15/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import UIKit
class KeyboardResponder: ObservableObject {
    
    @Published private(set) var currentHeight: CGFloat = 0
    
    private var notificationCenter: NotificationCenter

    init(center: NotificationCenter = .default) {
       notificationCenter = center
       notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }
    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
    deinit {
       notificationCenter.removeObserver(self)
    }
}
