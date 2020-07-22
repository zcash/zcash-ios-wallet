//
//  KeyPad.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct KeyPad: View {
    
    let keySize: CGFloat = 60
    let hSpacing: CGFloat = 50
    let vSpacing: CGFloat = 20
    
    var viewModel: KeyPadViewModel
    
    init(initialValue: Double = 0.0) {
        self.viewModel = KeyPadViewModel(initialValue: initialValue)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: self.vSpacing) {
                ForEach(self.viewModel.visibleValues, id: \.self) {
                    row in
                    HStack(alignment: .center, spacing: self.hSpacing) {
                        ForEach(row, id: \.self) { pad in
                            HStack {
                            Button(action: {
                                self.viewModel.valuePressed(pad)
                            }) {
                                    Text(pad)
                                    .font(.title)

                            }
                            .buttonStyle(KeyPadButtonStyle(size: self.keySize))
                                .cornerRadius(self.keySize/2)
                            }
                        }
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
            .frame(
                minWidth: size,
                maxWidth:  .infinity,
                minHeight:  size,
                maxHeight:  .infinity,
                alignment: .center
            )
            .contentShape(Circle())
            .animation(nil)
            .foregroundColor(configuration.isPressed ? Color.black : .white)
            .background(configuration.isPressed ? Color.white : .clear)
            .animation(.easeInOut(duration: 0.2))
    }
}

class KeyPadViewModel: ObservableObject {
    
    @Published var value: Double
    
    @Published var text: String
    
    static var formatter: NumberFormatter {
       NumberFormatter.zecAmountFormatter
    }
    
    var visibleValues: [[String]] {
        [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [Self.formatter.currencyDecimalSeparator, "0", "<"]
        ]
    }
    
    var validValues: Set<String> = ["1", "2", "3","4", "5", "6","7", "8", "9","0",KeyPadViewModel.formatter.currencyDecimalSeparator,"<"]
    
    init(initialValue: Double = 0) {
        
        guard initialValue > 0 else {
            text = ""
            value = 0
            return
        }
        
        let number = NSNumber(value: initialValue)
        
        if let textValue = Self.formatter.string(from: number) {
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
        case KeyPadViewModel.formatter.currencyDecimalSeparator:
            dotTapped()
        default:
            numberTapped(text)
        }
    }
    // this function assumes the given string contains a valid decimal number.
    func hasEightOrMoreDecimals(_ number: String) -> Bool {
        guard   Self.formatter.number(from: number) != nil, 
                let separatorString = Self.formatter.currencyDecimalSeparator,
                let separatorChar =  separatorString.first,
                let separatorIndex = number.firstIndex(of: separatorChar) else { return false }
        
        let lastIndex = number.endIndex
        
        return number.distance(from: number.index(separatorIndex, offsetBy: 1), to: lastIndex) >= 8
        
    }
    
    func numberTapped(_ number: String) {
        //catch leading zeros
        if text == "0" {
            if number == "0" {
                return
            } else {
                text = ""
            }
        }
        
        guard !hasEightOrMoreDecimals(text) else {
            return
        }
        
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
        
        guard !text.contains(KeyPadViewModel.formatter.currencyDecimalSeparator) else { return }
        
        let newText = text + KeyPadViewModel.formatter.currencyDecimalSeparator
        
        guard let newValue = doubleFromText(newText) else {
            return
        }
        
        text = newText
        value = newValue
        
    }
    
    func doubleFromText(_ textValue: String) -> Double? {
        Self.formatter.number(from: textValue)?.doubleValue
    }
    
}

struct KeyPad_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            KeyPad()
        }
    }
}
