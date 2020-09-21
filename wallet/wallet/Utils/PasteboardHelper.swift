//
//  PasteboardHelper.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/24/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import UIKit

struct PasteboardItemModel {
    var value: String
    var localizedStringKey: String
}

extension PasteboardItemModel: Identifiable {
    var id: String {
        value
    }
}


class PasteboardAlertHelper {
    
    static let shared = PasteboardAlertHelper()
        
    let publisher = PassthroughSubject<PasteboardItemModel,Never>()
    
    
    func copyToPasteBoard(value: String, notify localizedStringKey: String) {
        publisher.send(PasteboardItemModel(value: value, localizedStringKey: localizedStringKey))
        UIPasteboard.general.string = value
    }
    
    static func alert(for item: PasteboardItemModel) -> Alert {
        Alert(title: Text(""),
              message: Text(item.localizedStringKey),
              dismissButton: .default(Text("Close")))
    }
}
