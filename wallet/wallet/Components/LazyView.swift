//
//  LazyView.swift
//  wallet
//
//  Created by Francisco Gindre on 3/19/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
