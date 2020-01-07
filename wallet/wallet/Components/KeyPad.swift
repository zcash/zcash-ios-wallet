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
    
    var viewModel: KeyPadViewModel
    
    init(initialValue: Double = 0.0) {
        self.viewModel = KeyPadViewModel(initialValue: initialValue)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: vSpacing) {
            ForEach(self.viewModel.visibleValues, id: \.self) {
                row in
                HStack(alignment: .center, spacing: self.hSpacing) {
                    ForEach(row, id: \.self) { pad in
                        
                        Button(action: {
                            
                        }) {
                            Text(pad)
                        }.buttonStyle(KeyPadButtonStyle(size: self.keySize))
                            .frame(width: self.keySize, height: self.keySize)
                            .cornerRadius(self.keySize/2)
                    }
                }
            }
        }
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

class KeyPadViewModel: ObservableObject {
    
    @Published var value: Double
    
    var text: String
    
    var formatter: NumberFormatter {
        if value <= 0 {
            return NumberFormatter.zeroBalanceFormatter
        }
        return NumberFormatter.zecAmountFormatter
    }
    
    var visibleValues: [[String]] {
        [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [".", "0", "<"]
        ]
    }
    
    var validValues: Set<String> = ["1", "2", "3","4", "5", "6","7", "8", "9","0",".","<"]
    
    init(initialValue: Double = 0) {
        
        guard initialValue > 0 else {
            text = ""
            value = 0
            return
        }
        let number = NSNumber(value: initialValue)
        let formatter = initialValue <= 0 ? NumberFormatter.zeroBalanceFormatter : NumberFormatter.zecAmountFormatter
        
        if let textValue = formatter.string(from: number) {
            text = textValue
            value = initialValue
        } else {
            text = ""
            value = 0
        }
    }
    
    func valuePressed(_ text: String) {
        guard validValues.contains(text) else { return } // do nothing if value is invalid.
        switch text {
        case "<":
            deleteTapped()
        case ".":
            dotTapped()
        default:
            numberTapped(text)
        }
    }
    
    func numberTapped(_ number: String) {
        let newText = text + number
        
        guard let newValue = doubleFromText(newText) else {
            return
        }
        text = newText
        value = newValue
    }
    
    
    func clear() {
        text = ""
        value = 0
    }
    
    func deleteTapped() {
        guard text.count > 1 else {
            clear()
            return
        }
        
        let startIndex = text.startIndex
        let endIndex = text.index(startIndex, offsetBy: text.count - 1)
        let newText = String(text[startIndex ..< endIndex])
        
        guard let newValue = doubleFromText(newText) else {
            return
        }
        
        text = newText
        value = newValue
    }
    
    func dotTapped() {
        
        guard !text.contains(".") else { return }
        
        let newText = text + "."
        
        guard let newValue = doubleFromText(newText) else {
            return
        }
        
        text = newText
        value = newValue
        
    }
    
    func doubleFromText(_ textValue: String) -> Double? {
        formatter.number(from: textValue)?.doubleValue
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
