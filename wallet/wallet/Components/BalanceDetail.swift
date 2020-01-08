//
//  BalanceDetail.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

enum BalanceStatus {
    case available
    case expecting(zec: Double)
    case waiting(change: Double)
}


struct BalanceDetail: View {
    var availableZec: Double
    var status: BalanceStatus
    
    var available: some View {
        Text(format(zec: availableZec) + " ZEC")
            .foregroundColor(.white)
        + Text(" Available")
            .foregroundColor(Color.zAmberGradient1)
    }
    
    func format(zec: Double) -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: zec)) ?? "ERROR" //TODO: handle this weird stuff
    }
    
    var caption: some View {
        switch status {
        case .available:
            return Text("(tap in an amount to send)")
                .font(.body)
                .foregroundColor(Color.zLightGray)
            
        case .expecting(let zec):
            return  Text("(expecting ")
                           .font(.body)
                           .foregroundColor(Color.zLightGray) +
            Text("+" + format(zec: zec))
                           .font(.body)
                .foregroundColor(.white)
            + Text(" ZEC)")
                .font(.body)
                .foregroundColor(Color.zLightGray)
        
        case .waiting(let change):
            return  Text("(expecting ")
                                      .font(.body)
                                    .foregroundColor(Color.zLightGray) +
                       Text("+" + format(zec: change))
                                      .font(.body)
                           .foregroundColor(.white)
                       + Text(" ZEC in change)")
                           .font(.body)
                           .foregroundColor(Color.zLightGray)
        }
    }
    var body: some View {
        VStack(alignment: .center) {
            available
            caption
        }
    }
}

struct BalanceDetail_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 50) {
                BalanceDetail(availableZec: 2.0011,status: .available)
                BalanceDetail(availableZec: 0.0011,status: .expecting(zec: 2))
                BalanceDetail(availableZec: 12.2,status: .waiting(change: 5.3111112))
            }
            
        }
    }
}
