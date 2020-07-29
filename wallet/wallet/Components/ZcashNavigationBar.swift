//
//  ZcashNavigationBar.swift
//  wallet
//
//  Created by Francisco Gindre on 7/27/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashNavigationBar<LeadingContent: View, HeadingContent: View, TrailingContent: View>: View {
    
    var leadingItem: LeadingContent
    var headerItem: HeadingContent
    var trailingItem: TrailingContent
    
    init(@ViewBuilder leadingItem: () -> LeadingContent,
         @ViewBuilder headerItem: () -> HeadingContent,
         @ViewBuilder trailingItem: () -> TrailingContent) {
        self.leadingItem = leadingItem()
        self.headerItem = headerItem()
        self.trailingItem = trailingItem()
    }
    
    var body: some View {
        HStack {
            leadingItem
            Spacer()
            headerItem
            Spacer()
            trailingItem
        }
    }
}
//
//
//struct ZcashNavigationBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ZcashNavigationBar()
//    }
//}
