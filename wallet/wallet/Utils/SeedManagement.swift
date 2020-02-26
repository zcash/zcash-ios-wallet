//
//  SeedManagement.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import KeychainSwift
import ZcashLightClientKit
final class SeedManager {
    
    enum SeedManagerError: Error {
        case alreadyImported
        case uninitializedWallet
    }
    
    static var `default`: SeedManager = SeedManager()
    private static let zECCWalletKeys = "zECCWalletKeys"
    private static let zECCWalletSeedKey = "zEECWalletSeedKey"
    private static let zECCWalletBirthday = "zECCWalletBirthday"
    
    private let keychain = KeychainSwift()
    
    func importBirthday(_ height: BlockHeight) throws {
        guard keychain.get(Self.zECCWalletBirthday) == nil else {
            throw SeedManagerError.alreadyImported
        }
        keychain.set(String(height), forKey: Self.zECCWalletBirthday)
    }
    
    func exportBirthday() throws -> BlockHeight {
        guard let birthday = keychain.get(Self.zECCWalletBirthday),
            let value = BlockHeight(birthday) else {
                throw SeedManagerError.uninitializedWallet
        }
        return value
    }
    
    func importSeed(_ seed: String) throws {
        guard keychain.get(Self.zECCWalletSeedKey) == nil else { throw SeedManagerError.alreadyImported }
        keychain.set(seed, forKey: Self.zECCWalletSeedKey)
    }
    
    func exportSeed() throws -> String {
        guard let seed = keychain.get(Self.zECCWalletSeedKey) else { throw SeedManagerError.uninitializedWallet }
        return seed
    }
    
    func saveKeys(_ keys: [String]) {
        keychain.set(keys.joined(separator: ";"), forKey: Self.zECCWalletKeys)
    }
    
    func getKeys() -> [String]? {
        keychain.get(Self.zECCWalletKeys)?.split(separator: ";").map{String($0)}
    }
    
    /**
        Use carefully: Deletes the keys from the keychain
     */
    func nukeKeys() {
        keychain.delete(Self.zECCWalletKeys)
    }

    /**
       Use carefully: Deletes the seed from the keychain.
     */
    func nukeSeed() {
        keychain.delete(Self.zECCWalletSeedKey)
    }
    
    /**
     Use carefully: deletes the wallet birthday from the keychain
     */
    
    func nukeBirthday() {
        keychain.delete(Self.zECCWalletBirthday)
    }
    
    
    /**
    There's no fate but what we make for ourselves - Sarah Connor
    */
    func nukeWallet() {
        nukeKeys()
        nukeSeed()
        nukeBirthday()
    }
}

extension SeedManager: SeedProvider {
    func seed() -> [UInt8] {
        guard let s = try? exportSeed() else { return [] }
        return Array(s.utf8)
    }
}
