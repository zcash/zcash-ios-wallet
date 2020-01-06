//
//  KeyPad.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct KeyPad: View {
    
    //    @Published var amount: Double = 0.0
    let keySize: CGFloat = 60
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
                        KeyPadButton(size: self.keySize, text: pad)
                        .frame(width: self.keySize, height: self.keySize)
                        .cornerRadius(self.keySize/2)
                    }
                }
            }
        }
    }
}

struct KeyPadButton: View {
    let size: CGFloat
    var text: String
    var body: some View {
        Button(action: {
            
        }) {
            Text(text)
        }.buttonStyle(KeyPadButtonStyle(size: size))
        .frame(width: size, height: size)
    }
}

struct KeyPadButtonStyle: ButtonStyle {
    let size: CGFloat
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: size, maxWidth: size)
            .padding()
            .font(.title)
            .animation(nil)
            .foregroundColor(configuration.isPressed ? Color.black : .white)
            .background(configuration.isPressed ? Color.white : .clear)
            .animation(.easeInOut(duration: 0.2))
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
