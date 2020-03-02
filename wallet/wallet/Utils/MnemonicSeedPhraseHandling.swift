//
//  MnemonicSeedPhraseHandling.swift
//  wallet
//
//  Created by Francisco Gindre on 2/28/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
enum MnemonicError: Error {
    case invalidSeed
}

protocol MnemonicSeedPhraseHandling {
    /**
     random 24 words mnemonic phrase
     */
    func randomMnemonic() -> String?
    /**
    random 24 words mnemonic phrase as array of words
    */
    func randomMnemonicWords() -> [String]?
    
    /**
     generate deterministic seed from mnemonic phrase
     */
    func toSeed(mnemonic: String) -> [UInt8]?
    
    /**
     get this mnemonic
    */
    func asWords(mnemonic: String) -> [String]?
    
    /**
     validates whether the given mnemonic is correct
     */
    func isValid(mnemonic: String) -> Bool
}
