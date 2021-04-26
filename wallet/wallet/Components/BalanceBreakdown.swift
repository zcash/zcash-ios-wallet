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
            Text("SHIELDED ZEC")
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
                              amount: model.transparent.total,
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
    let dimLastDecimalPlaces: Int
    let breakdown: (String,String)
    
    init(amount: Double,
         count: Int = 10,
         formatter: NumberFormatter = NumberFormatter.zecAmountFormatter,
         dimLastDecimalPlaces: Int = 5)  {
        self.amount = amount
        self.count = count
        self.formatter = formatter
        self.dimLastDecimalPlaces = dimLastDecimalPlaces
        self.breakdown = Self.breakAmountDown()
    }
    
    static func breakAmountDown() -> (String, String) {
        ("20.944","31563")
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
        fmt.maximumFractionDigits = 8
        fmt.minimumFractionDigits = 1
        fmt.minimumIntegerDigits = 1
        fmt.maximumIntegerDigits = 9
        fmt.generatesDecimalNumbers = true
        
        return fmt
        
    }
}
