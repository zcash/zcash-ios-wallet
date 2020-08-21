//
//  BlockExplorerUrlHandling.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/21/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit
class UrlHandler {
    
    static func blockExplorerURL(for txId: String) -> URL? {
        blockExplorerURL(for: txId, mainnet: ZcashSDK.isMainnet)
    }
    
    static func blockExplorerURL(for txId: String, mainnet: Bool = false) -> URL? {
        var urlComponents = URLComponents()
        let baseURL = mainnet ? "explorer.z.cash" : "explorer.testnet.z.cash"
        urlComponents.host = baseURL
        urlComponents.scheme = "https"
        urlComponents.path = "/tx"
        
        return urlComponents.url?.appendingPathComponent(txId)
    }
}
