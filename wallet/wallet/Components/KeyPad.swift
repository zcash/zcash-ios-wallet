//
//  KeyPad.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct KeyPad: View {
    let hSpacing: CGFloat = 50
    let vSpacing: CGFloat = 20
    let values = [
                  ["1", "2", "3"],
                  ["4", "5", "6"],
                  ["7", "8", "9"],
                  [".", "0", "<"]
                ]
    var body: some View {
        VStack(alignment: .center, spacing: vSpacing) {
            ForEach(values, id: \.self) {
                row in
                HStack(alignment: .center, spacing: self.hSpacing) {
                    ForEach(row, id: \.self) { pad in
                        KeyPadButton(text: pad)
                    }
                }
            }
        }
    }
}

struct KeyPadButton: View {
    
    var text: String
    var body: some View {
        Text(text)
        .foregroundColor(.white)
        .font(.title)
        .padding()
        .frame(width: 60, height: 60)
    }
}

struct KeyPad_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Background()
            KeyPad()
        }
    }
}
