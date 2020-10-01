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

extension View {
    func zcashNavigationBar<LeadingContent: View,
                            HeadingContent: View,
                            TrailingContent: View>(
                                                    @ViewBuilder leadingItem: () -> LeadingContent,
                                                    @ViewBuilder headerItem: () -> HeadingContent,
                                                    @ViewBuilder trailingItem: () -> TrailingContent) -> some View {
        self.modifier(ZcashNavigationBarModifier(leadingItem:
                                                    leadingItem,
                                                 headerItem: headerItem,
                                                 trailingItem: trailingItem)
        )
    }
}
struct ZcashNavigationBarModifier<LeadingContent: View, HeadingContent: View, TrailingContent: View>: ViewModifier {
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
    
    func body(content: Content) -> some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 0) {
                ZcashNavigationBar(leadingItem: { leadingItem },
                                   headerItem: { headerItem },
                                   trailingItem: { trailingItem } )
                    .padding(.horizontal, 10)
                content
            }
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
