//
//  TabSelector.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 4/23/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI



struct BoundsKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?,
                       nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

struct ForegroundColor: PreferenceKey {
    static var defaultValue: Color? = nil
    static func reduce(value: inout Color?, nextValue: () -> Color?) {
        value = value ?? nextValue()
    }
}
struct TabSelector<Content: View>: View {
    let tabs: [(Content, Color)]
    @Binding var selectedTabIndex: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(tabs.indices) { tabIndex in
                Button(action: {
                    self.selectedTabIndex = tabIndex
                }, label: {
                    self.tabs[tabIndex].0
                        .foregroundColor(
                            tabIndex == selectedTabIndex ? self.tabs[tabIndex].1 : Color.zGray3
                        )
                    
                })
                .anchorPreference(key: BoundsKey.self, value: .bounds, transform: {
                    anchor in
                    self.selectedTabIndex == tabIndex ? anchor : nil
                })
                
            }
        }
        .overlayPreferenceValue(BoundsKey.self, { anchor in
            GeometryReader { proxy in
                Rectangle()
                    .fill(tabs[selectedTabIndex].1)
                    .frame(width: proxy[anchor!].width, height: 2)
                    .offset(x: proxy[anchor!].minX)
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: .bottomLeading
                    )
                    .animation(.default)
            }
        })
        
    }
}

