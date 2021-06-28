//
//  AutoShieldingTests.swift
//  ECC-WalletTests
//
//  Created by Francisco Gindre on 6/25/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import XCTest
import Combine

@testable import ECC_Wallet_Testnet
class AutoShieldingTests: XCTestCase {
    var cancellables = [AnyCancellable]()
    func testAutoShield() throws {
        let mockShielder = MockShielder(strategy: MockFailedManualStrategy(),
                                        shielder: MockSuccessfulShieldingCapable(),
                                        keyProviding: MockKeyProviding(),
                                        keyDeriver: MockKeyDeriving())
        
        let expectation = XCTestExpectation(description: "Shield Expectation")
        
        mockShielder.shield()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                expectation.fulfill()
                switch completion {
                case .failure(let error):
                    XCTFail("failed with error: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { result in
                expectation.fulfill()
                switch result {
                case .notNeeded:
                    XCTFail("manual shielding is always needed")
                case .shielded:
                    XCTAssertTrue(true)
                }
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 4)
    }
    
    func testAutoShieldFails() throws {
        let mockShielder = MockShielder(strategy: MockFailedManualStrategy(),
                                        shielder: MockFailureShieldingCapable(),
                                        keyProviding: MockKeyProviding(),
                                        keyDeriver: MockKeyDeriving())
        
        let expectation = XCTestExpectation(description: "Shield Expectation")
        
        mockShielder.shield()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                expectation.fulfill()
                switch completion {
                case .failure(let error):
                    switch error {
                    case ShieldFundsError.insuficientTransparentFunds:
                        XCTAssertTrue(true)
                    default:
                        XCTFail("failed with error: \(error)")
                    }
                case .finished:
                    break
                }
            } receiveValue: { result in
                expectation.fulfill()
                switch result {
                case .notNeeded:
                    XCTFail("manual shielding is always needed")
                case .shielded:
                    XCTFail("this test should have failed")
                }
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 4)
    }
    
    func testAutoShieldNonNeeded() {
        let mockShielder = MockShielder(strategy: MockFailedManualStrategy(),
                                        shielder: MockSuccessfulShieldingCapable(),
                                        keyProviding: MockKeyProviding(),
                                        keyDeriver: MockKeyDeriving())
        
        let expectation = XCTestExpectation(description: "Shield Expectation")
        
        mockShielder.shield()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                expectation.fulfill()
                switch completion {
                case .failure(let error):
                    XCTFail("failed with error: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { result in
                expectation.fulfill()
                switch result {
                case .notNeeded:
                    XCTAssertTrue(true)
                case .shielded:
                    XCTFail("this test should have failed")
                }
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 4)
    }
}


class MockShielder: AutoShielder {
    var keyDeriver: KeyDeriving
    var keyProviding: ShieldingKeyProviding
    var shielder: ShieldingCapable
    var strategy: AutoShieldingStrategy
    
    init(strategy: AutoShieldingStrategy,
         shielder: ShieldingCapable,
         keyProviding: ShieldingKeyProviding,
         keyDeriver: KeyDeriving) {
        self.strategy = strategy
        self.shielder = shielder
        self.keyProviding = keyProviding
        self.keyDeriver = keyDeriver
    }
}

class MockShieldNotNeeded: AutoShieldingStrategy {
    func shield(autoShielder: AutoShielder) -> Future<AutoShieldingResult, Error> {
        Future<AutoShieldingResult, Error> { promise in
            promise(.success(AutoShieldingResult.notNeeded))
        }
    }
    
    var shouldAutoShield: Bool {
        false
    }
    /**
     throws no UTXO found because this shouldn't be called if autoshield not needed
     */
    func shield() -> Future<AutoShieldingResult, Error> {
        Future<AutoShieldingResult, Error> { promise in
            promise(.failure(ShieldFundsError.noUTXOFound))
        }
    }
}
class MockSuccessfulManualStrategy: AutoShieldingStrategy {
    func shield(autoShielder: AutoShielder) -> Future<AutoShieldingResult, Error> {
        Future<AutoShieldingResult,Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                promise(.success(.shielded(pendingTx: MockPendingTx())))
            })
        }
        
    }
    
    var shouldAutoShield: Bool {
        true
    }
    
}

class MockFailedManualStrategy: AutoShieldingStrategy {
    /**
     throws ShieldFundsError.insuficientTransparentFunds) after 2 seconds
     */
    func shield(autoShielder: AutoShielder) -> Future<AutoShieldingResult, Error> {
        Future<AutoShieldingResult,Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                promise(.failure(ShieldFundsError.insuficientTransparentFunds))
            })
        }
    }
    
    var shouldAutoShield: Bool {
        false
    }
}
import ZcashLightClientKit

struct MockPendingTx: PendingTransactionEntity {
    var toAddress = "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr"
    
    var accountIndex: Int = 0
    
    var minedHeight: BlockHeight = -1
    
    var expiryHeight: BlockHeight = 123456780
    
    var cancelled: Int = 0
    
    var encodeAttempts: Int = 1
    
    var submitAttempts: Int = 1
    
    var errorMessage: String? = nil
    
    var errorCode: Int? = nil
    
    var createTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    
    func isSameTransactionId<T>(other: T) -> Bool where T : RawIdentifiable {
        false
    }
    
    var raw: Data? = Data()
    
    var id: Int? = 1
    
    var value: Int = 120000
    
    var memo: Data? = nil
    
    var rawTransactionId: Data? = Data()
    
}

class MockSuccessfulShieldingCapable: ShieldingCapable {
    func shieldFunds(spendingKey: String, transparentSecretKey: String, memo: String?, from accountIndex: Int, resultBlock: @escaping (Result<PendingTransactionEntity, Error>) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2, execute: {
            resultBlock(.success(MockPendingTx()))
        })
    }
}

class MockFailureShieldingCapable: ShieldingCapable {
    func shieldFunds(spendingKey: String, transparentSecretKey: String, memo: String?, from accountIndex: Int, resultBlock: @escaping (Result<PendingTransactionEntity, Error>) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2, execute: {
            resultBlock(.failure(ShieldFundsError.insuficientTransparentFunds))
        })
    }
}


class MockKeyProviding: ShieldingKeyProviding {
    func getTransparentSecretKey() throws -> PrivateKeyAccountIndexPair {
        ("someFakeKey", 0, 0)
    }
    
    func getSpendingKey() throws -> PrivateKeyAccountIndexPair {
        ("someFakeSpendingKey", 0, 0)
    }
}

enum MockError: Error {
    case notImplemented
}
class MockKeyDeriving: KeyDeriving {
    func deriveViewingKeys(seed: [UInt8], numberOfAccounts: Int) throws -> [String] {
        throw MockError.notImplemented
    }
    
    func deriveViewingKey(spendingKey: String) throws -> String {
        throw MockError.notImplemented
    }
    
    func deriveSpendingKeys(seed: [UInt8], numberOfAccounts: Int) throws -> [String] {
        throw MockError.notImplemented
    }
    
    func deriveShieldedAddress(seed: [UInt8], accountIndex: Int) throws -> String {
        throw MockError.notImplemented
    }
    
    func deriveShieldedAddress(viewingKey: String) throws -> String {
        throw MockError.notImplemented
    }
    
    func deriveTransparentAddress(seed: [UInt8], account: Int, index: Int) throws -> String {
        throw MockError.notImplemented
    }
    
    func deriveTransparentPrivateKey(seed: [UInt8], account: Int, index: Int) throws -> String {
        throw MockError.notImplemented
    }
    
    func deriveTransparentAddressFromPrivateKey(_ tsk: String) throws -> String {
        "tMockAddressfldkfjarqwer3oiufal"
    }
    
    func deriveTransparentAddressFromPublicKey(_ pubkey: String) throws -> String {
        throw MockError.notImplemented
    }
    
    func deriveUnifiedViewingKeysFromSeed(_ seed: [UInt8], numberOfAccounts: Int) throws -> [UnifiedViewingKey] {
        throw MockError.notImplemented
    }
    
    func deriveUnifiedAddressFromUnifiedViewingKey(_ uvk: UnifiedViewingKey) throws -> UnifiedAddress {
        throw MockError.notImplemented
    }
}
