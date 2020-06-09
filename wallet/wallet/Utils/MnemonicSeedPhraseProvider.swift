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
    
    func randomMnemonic() -> String? {
        Mnemonic.generateMnemonic(strength: 256)
    }
    
    func randomMnemonicWords() -> [String]? {
        randomMnemonic()?.split(separator: " ").map({ String($0) })
    }
    
    func toSeed(mnemonic: String) -> [UInt8]? {
        guard let data = Mnemonic.deterministicSeedBytes(from: mnemonic) else { return nil }
        return [UInt8](data)
    }
    
    func asWords(mnemonic: String) -> [String]? {
        mnemonic.split(separator: " ").map({ String($0) })
    }
    
    func isValid(mnemonic: String) -> Bool {
        Mnemonic.validate(mnemonic: mnemonic)
    }
}
