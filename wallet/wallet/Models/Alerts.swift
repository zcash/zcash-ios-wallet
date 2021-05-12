//
//  Alerts.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 3/13/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation


enum AlertType {
    case error(underlyingError: Error)
    case feedback(message: String, action: (() -> Void)?)
    case actionable(title: String,
                    message: String,
                    destructiveText: String,
                    destructiveAction: (() -> Void),
                    dismissText: String,
                    dismissAction:(() -> Void))
}


struct AlertItem: Identifiable {
    let id = UUID()
    let type: AlertType
}

import SwiftUI
extension AlertItem {
    func asAlert() -> Alert {
        type.asAlert()
    }
}

extension AlertType {
    
    func asAlert() -> Alert {
        switch self {
        case .error(let underlyingError):
            return Alert(title: Text("Error"),
                         message: Text("An error occured \(underlyingError.localizedDescription)"),
                         dismissButton: .default(Text("dismiss")))
        case .feedback(let message,
                       let action):
            return Alert(title: Text(""),
                         message: Text(message),
                         dismissButton: .default(Text("dismiss"), action: action))
        case .actionable(let title,
                         let message,
                         let destructiveText,
                         let destructiveAction,
                         let dismissText,
                         let dismissAction):
            return Alert(title: Text(title),
                         message: Text(message),
                         primaryButton: .destructive(Text(destructiveText), action: destructiveAction),
                         secondaryButton: .default(Text(dismissText), action: dismissAction))
            
            
        }
    }
}
