//
//  BalanceDetail.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

enum BalanceStatus {
    case available(showCaption: Bool)
    case expecting(zec: Double)
    case waiting(change: Double)
}

struct BalanceDetail: View {
    var availableZec: Double
    var status: BalanceStatus
    
    var available: some View {
        Text(format(zec: availableZec) + " ZEC ")
            .foregroundColor(.zLightGray)
        + Text("balance_available")
            .foregroundColor(Color.zAmberGradient1)
    }
    
    func format(zec: Double) -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: zec)) ?? "ERROR" //TODO: handle this weird stuff
    }
    var includeCaption: Bool {
        switch status {
        case .available(_):
            return false
        default:
            return true
        }
    }
    var caption: some View {
        switch status {
        case .expecting(let zec):
            return  Text("(\("expecting".localized()) ")
                           .font(.body)
                           .foregroundColor(Color.zLightGray) +
            Text("+" + format(zec: zec))
                           .font(.body)
                .foregroundColor(.white)
            + Text(" ZEC)")
                .font(.body)
                .foregroundColor(Color.zLightGray)
        
        case .waiting(let change):
            return  Text("(\("expecting".localized()) ")
                                      .font(.body)
                                    .foregroundColor(Color.zLightGray) +
                       Text("+" + format(zec: change))
                                      .font(.body)
                           .foregroundColor(.white)
                       + Text(" ZEC)")
                           .font(.body)
                           .foregroundColor(Color.zLightGray)
            default:
                return Text("")
        }
    }
    var body: some View {
        VStack(alignment: .center) {
            available
            if includeCaption {
                caption
            }
        }
    }
}

struct BalanceDetail_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 50) {
                BalanceDetail(availableZec: 2.0011,status: .available(showCaption: true))
                BalanceDetail(availableZec: 0.0011,status: .expecting(zec: 2))
                BalanceDetail(availableZec: 12.2,status: .waiting(change: 5.3111112))
            }
        }
    }
}

extension ZECCWalletEnvironment {
    var balanceStatus: BalanceStatus {
        let verifiedBalance = self.initializer.getVerifiedBalance().asHumanReadableZecBalance()
        let balance = self.initializer.getBalance().asHumanReadableZecBalance()
        
        let difference = verifiedBalance - balance
        if difference.isZero {
            return BalanceStatus.available(showCaption: true)
        } else if difference > 0 {
            return BalanceStatus.expecting(zec: abs(difference))
        } else {
            return BalanceStatus.waiting(change: abs(difference))
        }
    }
}
