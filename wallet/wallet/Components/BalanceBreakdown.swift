//
//  BalanceBreakdown.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 4/26/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI


final class BalanceBreakdownViewModel: ObservableObject {
    var transparent = ReadableBalance.zero
    var shielded = ReadableBalance.zero
    
    init(shielded: ReadableBalance, transparent: ReadableBalance) {
        self.shielded = shielded
        self.transparent = transparent
    }
}

struct BalanceBreakdown: View {
    @State var model: BalanceBreakdownViewModel
    
    @ViewBuilder var shieldedZecTitle: some View {
        HStack {
            Image("ic_shieldtick_yellow")
                .resizable()
                .frame(width: 13, height: 16, alignment: .center)
            Text("SHIELDED ZEC")
                .font(.system(size: 14))
                .foregroundColor(.zYellow)
        }
    }
    
    @ViewBuilder func boringTitle(localizedKey: LocalizedStringKey) ->  some View {
        Text(localizedKey)
            .foregroundColor(.zDudeItsAlmostWhite)
            .font(.system(size: 14))
    }
    
    var body: some View {
        ZStack {
            ZcashBackground(backgroundColor: .black, colors: [.zBalanceBreakdownGradient1, .zBalanceBreakdownGradient1], showGradient: true)
            VStack(alignment: .center, spacing: 4, content: {
                BreakdownItem(title: shieldedZecTitle,
                              amount: model.shielded.total,
                              backgroundColor: .zBalanceBreakdownItem0)
                
                BreakdownItem(title: boringTitle(localizedKey: "+ TRANSPARENT"),
                              amount: model.transparent.total,
                              backgroundColor: .zBalanceBreakdownItem1)
                
                BreakdownItem(title: boringTitle(localizedKey: "= TOTAL"),
                              amount: model.transparent.total + model.shielded.total,
                              backgroundColor: .zBalanceBreakdownItem2)
                
            })
            .padding(16)
        }
    }
}


struct BreakdownItem<TitleContent: View>: View {
    var title: TitleContent
    var amount: Double
    var backgroundColor = Color.zGray
    
    var body: some View {
        ZStack {
            backgroundColor
            VStack(alignment: .leading, spacing: 3, content: {
                title
                AmountBreakdown(model: AmountBreakdownViewModel(amount: amount))
            })
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
        }
    }
}

final class AmountBreakdownViewModel: ObservableObject {
    let amount: Double
    let count: Int
    let formatter: NumberFormatter
    let highlightingDecimals: Int
    let breakdown: (String,String)
    
    init(amount: Double,
         count: Int = 10,
         formatter: NumberFormatter = NumberFormatter.zecAmountBreakdownFormatter,
         highlightingDecimals: Int = 3)  {
        self.amount = amount
        self.count = count
        self.formatter = formatter
        self.highlightingDecimals = highlightingDecimals
        self.breakdown = Self.breakAmountDown(value: amount, count: count, formatter: formatter, highlightingDecimals: highlightingDecimals)
    }
    
    static func breakAmountDown(value: Double, count: Int, formatter: NumberFormatter, highlightingDecimals: Int) -> (String, String) {
        
        func pad(_ formattedAmount: String, hasDecimals: Bool ) -> String {
            if hasDecimals {
                // this string has fractions. either needs to be padded or trimmed to meet count
                return formattedAmount.padding(toLength: count + 1, withPad: "0", startingAt: 0 )
            } else {
                // does not have a decimal fraction. append a
                return formattedAmount.appending(formatter.decimalSeparator).padding(toLength: count + 1, withPad: "0", startingAt: 0 )
            }
        }
        
        guard let formattedAmount = formatter.string(for: value) else {
            return ("","")
        }
        
        let hasDecimals = formattedAmount.contains(formatter.decimalSeparator)
        
        let properlyPaddedFormattedAmount = pad(formattedAmount, hasDecimals: hasDecimals)
        
        if highlightingDecimals >= count {
            return ("",properlyPaddedFormattedAmount)
        }

        let endIndex = properlyPaddedFormattedAmount.endIndex
        
        
        // If the number has no decimals or padding got rid of them return the whole string on compoenent 0
        guard hasDecimals,
              let rangeOfDecimalSeparator = properlyPaddedFormattedAmount.range(of: formatter.decimalSeparator),
              rangeOfDecimalSeparator.lowerBound != endIndex
        else {
            return (properlyPaddedFormattedAmount, "")
        }
        
        // split the amount into tuple
        let startIndex = properlyPaddedFormattedAmount.startIndex
        
        // find out how many decimals there are after padding
        
        let decimals = properlyPaddedFormattedAmount.distance(from: rangeOfDecimalSeparator.lowerBound, to: endIndex)
        

        if decimals > highlightingDecimals {
            let highlightUntilIndex = properlyPaddedFormattedAmount.index(rangeOfDecimalSeparator.upperBound, offsetBy: highlightingDecimals )
            return (
                String(properlyPaddedFormattedAmount[startIndex ..< highlightUntilIndex]),
                String(properlyPaddedFormattedAmount[highlightUntilIndex ..< endIndex]))
        } else {
            return (properlyPaddedFormattedAmount, "")
        }
    }
}

struct AmountBreakdown: View {
    
    @State var model: AmountBreakdownViewModel
    
    var body: some View {
        Text("$"+model.breakdown.0)
            .foregroundColor(.white)
            .font(.zoboto(size: 42))
        +
        Text(model.breakdown.1)
            .foregroundColor(.zLeastSignificantAmountGray)
            .font(.zoboto(size: 42))
            
    }
}

extension NumberFormatter {
    static var zecAmountBreakdownFormatter: NumberFormatter {
        
        let fmt = NumberFormatter()
        
        fmt.alwaysShowsDecimalSeparator = false
        fmt.allowsFloats = true
        fmt.maximumFractionDigits = 9
        fmt.minimumFractionDigits = 1
        fmt.minimumIntegerDigits = 1
        fmt.maximumIntegerDigits = 10
        fmt.generatesDecimalNumbers = true
        
        return fmt
        
    }
}
