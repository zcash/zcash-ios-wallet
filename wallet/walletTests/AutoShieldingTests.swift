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
        let mockShielder = MockShielder(strategy: MockSuccessfulManualStrategy())
        
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
        let mockShielder = MockShielder(strategy: MockFailedManualStrategy())
        
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
        let mockShielder = MockShielder(strategy: MockShieldNotNeeded())
        
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
    var strategy: AutoShieldingStrategy
    
    init(strategy: AutoShieldingStrategy) {
        self.strategy = strategy
    }
    
}

class MockShieldNotNeeded: AutoShieldingStrategy {
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
    var shouldAutoShield: Bool {
        true
    }
    
    func shield() -> Future<AutoShieldingResult, Error> {
        Future<AutoShieldingResult,Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                promise(.success(.shielded(pendingTx: MockPendingTx())))
            })
        }
    }
}

class MockFailedManualStrategy: AutoShieldingStrategy {
    var shouldAutoShield: Bool {
        true
    }
    /**
     throws ShieldFundsError.insuficientTransparentFunds) after 2 seconds
     */
    func shield() -> Future<AutoShieldingResult, Error> {
        Future<AutoShieldingResult,Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                promise(.failure(ShieldFundsError.insuficientTransparentFunds))
            })
        }
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
