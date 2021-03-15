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
    case feedback(message: String)
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
            return Alert(title: Text("Error"), message: Text("An error occured \(underlyingError.localizedDescription)"), dismissButton: .default(Text("dismiss")))
        case .feedback(let message):
            return Alert(title: Text(""),message: Text(message), dismissButton: .default(Text("dismiss")))
        }
    }
}
