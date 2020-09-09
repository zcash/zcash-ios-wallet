//
//  MnemonicSeedPhraseProvider.swift
//  wallet
//
//  Created by Francisco Gindre on 2/28/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import MnemonicSwift
class MnemonicSeedProvider: MnemonicSeedPhraseHandling {
    
    static let `default` = MnemonicSeedProvider()
       
    private init(){}
    
    func randomMnemonic() throws -> String {
        try Mnemonic.generateMnemonic(strength: 256)
    }
    
    func randomMnemonicWords() throws -> [String] {
        try randomMnemonic().components(separatedBy: " ")
    }
    
    func toSeed(mnemonic: String) throws -> [UInt8] {
        let data = try Mnemonic.deterministicSeedBytes(from: mnemonic)
        return [UInt8](data)
    }
    
    func asWords(mnemonic: String) throws -> [String] {
        mnemonic.components(separatedBy: " ")
    }
    
    func isValid(mnemonic: String) throws {
        try Mnemonic.validate(mnemonic: mnemonic)
    }
}
