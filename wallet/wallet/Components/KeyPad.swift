//
//  KeyPad.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct KeyPad: View {
    
    let keySize: CGFloat = 50
    let hSpacing: CGFloat = 10
    let vSpacing: CGFloat = 5
    
    var viewModel: KeyPadViewModel
    
    init(value: Binding<String>) {
        self.viewModel = KeyPadViewModel(value: value)
    }
    
    var body: some View {
            VStack(alignment: .center, spacing: self.vSpacing) {
                ForEach(self.viewModel.visibleValues, id: \.self) {
                    row in
                    HStack(alignment: .center, spacing: self.hSpacing) {
                        ForEach(row, id: \.self) { pad in
                            HStack {
                                if pad == "<" {
                                    Button(action: {
                                        self.viewModel.valuePressed(pad)
                                    }) {
                                            Text(pad)
                                            .font(.title)

                                    }
                                    .buttonStyle(KeyPadButtonStyle(size: self.keySize))
                                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                                        self.viewModel.clear()
                                    })
                                } else {
                                    Button(action: {
                                        self.viewModel.valuePressed(pad)
                                    }) {
                                            Text(pad)
                                            .font(.title)

                                    }
                                    .buttonStyle(KeyPadButtonStyle(size: self.keySize))
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
            .background(Circle().fill(configuration.isPressed ? Color.white : .clear))
            .animation(.easeInOut(duration: 0.2))
    }
}

class KeyPadViewModel: ObservableObject {
    
    @Binding var value: String

    
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
    
    init(value: Binding<String>) {
        self._value = value
        if self.value.isEmpty {
            self.value = "0"
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
        if value == "0" {
            if number == "0" {
                return
            } else {
                value = ""
            }
        }
        
        guard !hasEightOrMoreDecimals(value) else {
            return
        }
        
        let newText = value + number
        
        guard let _ = doubleFromText(newText) else {
            return
        }
        value = newText
        
    }
    
    
    func clear() {
        value = "0"
    }
    
    func deleteTapped() {
        guard value.count > 1 else {
            clear()
            return
        }
        
        let startIndex = value.startIndex
        let endIndex = value.index(startIndex, offsetBy: value.count - 1)
        let newText = String(value[startIndex ..< endIndex])
        
        guard let _ = doubleFromText(newText) else {
            return
        }
        
        value = newText
    }
    
    func dotTapped() {
        
        guard !value.contains(KeyPadViewModel.formatter.currencyDecimalSeparator) else { return }
        
        let newText = (value.isEmpty ? "0" : value) + KeyPadViewModel.formatter.currencyDecimalSeparator
        
        guard let _ = doubleFromText(newText) else {
            return
        }
        
        value = newText
        
    }
    
    func doubleFromText(_ textValue: String) -> Double? {
        Self.formatter.number(from: textValue)?.doubleValue
    }
    
}

struct KeyPad_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            KeyPad(value: .constant(""))
        }
    }
}
