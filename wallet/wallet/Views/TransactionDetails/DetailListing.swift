//
//  DetailListing.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 8/18/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct DetailListing: View {
    var spacingLastItem: Bool = true
    var details: [AnyView]
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(0 ..< details.count - 1, id: \.self) {
                index in
                self.details[index]
            }
            if spacingLastItem {
                Spacer()
            }
            self.details[self.details.count - 1]
        }
    }
}

struct DetailListing_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            DetailListing(details: [
                Text("+0.0001 network fee")
                    .font(.body)
                    .foregroundColor(.gray)
                .eraseToAnyView(),
                Text("from your shielded wallet")
                .font(.body)
                .foregroundColor(.gray)
                .eraseToAnyView(),
                Text("with a memo")
                .font(.body)
                .foregroundColor(.gray)
                .eraseToAnyView(),
                Text("to zs17mg40levj...y3kmwuz8k55a")
                .font(.body)
                .foregroundColor(.gray)
                .eraseToAnyView(),
                Text("Confirmed")
                .font(.body)
                .foregroundColor(.gray)
                .eraseToAnyView()
                
            ])
        }
    }
}
