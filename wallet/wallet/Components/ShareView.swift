//
//  ShareView.swift
//  Zircles
//
//  Created by Francisco Gindre on 7/3/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

enum ShareItem: Identifiable {
    
    case text(text: String)
    case file(fileUrl: URL)
    
    var id: String {
        switch self {
        case .file:
            return "file"
        case .text:
            return "text"
        }
    }
    
    var activityItem: Any {
        switch self {
        case .file(let fileUrl):
            return fileUrl
        case .text(let text):
            return text
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
