//
//  SeedManagement.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import KeychainSwift

final class SeedManager {
    
    enum SeedManagerError: Error {
        case alreadyImported
        case uninitializedWallet
    }
    
    static var `default`: SeedManager = SeedManager()
    
    private static let zECCWalletSeedKey = "zEECWalletSeedKey"
    private let keychain = KeychainSwift()
    
    func importSeed(_ seed: String) throws {
        guard keychain.get(Self.zECCWalletSeedKey) == nil else { throw SeedManagerError.alreadyImported }
        keychain.set(seed, forKey: Self.zECCWalletSeedKey)
    }
    
    func exportSeed() throws -> String {
        guard let seed = keychain.get(Self.zECCWalletSeedKey) else { throw SeedManagerError.uninitializedWallet }
        return seed
    }
    
    /**
       Use carefully: Deletes the seed from the keychain.
     */
    func nukeSeed() throws {
        guard keychain.get(Self.zECCWalletSeedKey) != nil else { throw SeedManagerError.uninitializedWallet }
        keychain.delete(Self.zECCWalletSeedKey)
    }
}
