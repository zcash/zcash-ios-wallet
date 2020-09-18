//
//  ZecAmountHeader.swift
//  wallet
//
//  Created by Francisco Gindre on 7/27/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

enum WalletType {
    case shielded
}

extension WalletType {
    var localizedString: String {
        switch self {
        case .shielded:
            return NSLocalizedString("send_fromshielded", comment: "")
        }
    }
}

struct ZecAmountHeader: View {
        
    let walletType: WalletType = .shielded
    var amount: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("$\(amount)")
                .font(.zoboto(size: 36))
                .foregroundColor(.white)
            Text(walletType.localizedString)
                .font(.footnote)
                .foregroundColor(.white)
        }
    }
}

struct ZecAmountHeader_Previews: PreviewProvider {
    static var previews: some View {
        ZecAmountHeader(amount: "20.1")
    }
}
