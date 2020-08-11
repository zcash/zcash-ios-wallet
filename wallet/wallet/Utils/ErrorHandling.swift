//
//  ErrorHandling.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

enum WalletError: Error {
    case createFailed
    case initializationFailed(message: String)
    case synchronizerFailed
    case genericErrorWithMessage(message: String)
    case genericErrorWithError(error: Error)
    case networkTimeout
    case connectionFailed
    case connectionFailedWithError(error: Error)
    case maxRetriesReached(attempts: Int)
    case sendFailed(error: Error)
    case criticalError
}

func trackError(_ walletError: WalletError) -> WalletError {
    switch walletError {
    case .criticalError, .createFailed:
        tracker.track(.error(severity: .critical), properties: [ ErrorSeverity.underlyingError : walletError.localizedDescription ])
    case .initializationFailed(message: let message):
        tracker.track(.error(severity: .critical), properties: [ ErrorSeverity.underlyingError : walletError.localizedDescription,
                                                                 ErrorSeverity.messageKey : message ])
    case .synchronizerFailed:
        tracker.track(.error(severity: .noncritical), properties: [ ErrorSeverity.underlyingError : walletError.localizedDescription])
    case .genericErrorWithMessage(message: let message):
        tracker.track(.error(severity: .noncritical), properties: [ ErrorSeverity.underlyingError : walletError.localizedDescription,
                                                                    ErrorSeverity.messageKey : message ])
    case .genericErrorWithError(let error):
        tracker.track(.error(severity: .noncritical), properties: [ ErrorSeverity.underlyingError : error.localizedDescription
        ])
    case .networkTimeout:
        tracker.track(.error(severity: .warning), properties: [ ErrorSeverity.underlyingError : walletError.localizedDescription
        ])
    case .connectionFailed:
        tracker.track(.error(severity: .warning), properties: [ ErrorSeverity.underlyingError : walletError.localizedDescription
        ])
    case .connectionFailedWithError(error: let error):
        tracker.track(.error(severity: .warning), properties: [ ErrorSeverity.underlyingError : error.localizedDescription
        ])
    case .maxRetriesReached:
        break // don't log
    
    case .sendFailed(let error):
        tracker.track(.error(severity: .warning), properties: [ ErrorSeverity.underlyingError : error.localizedDescription
        ])
    }
    return walletError
}

func mapToUserFacingError(_ walletError: WalletError) -> UserFacingErrors {
    switch walletError {

    case .createFailed:
        return .initalizationFailed
    case .initializationFailed:
        return .initalizationFailed
    case .synchronizerFailed:
        return .synchronizerError(canRetry: false)
    case .genericErrorWithMessage:
        return .internalError
    case .genericErrorWithError:
        return .internalError
    case .networkTimeout:
        return .connectionFailed
    case .connectionFailed:
        return .connectionFailed
    case .connectionFailedWithError:
        return .connectionFailed
    case .maxRetriesReached(_):
        return .synchronizerError(canRetry: true)
    case .sendFailed:
        return .transactionSubmissionError
    case .criticalError:
        return .criticalError
    }
}

enum UserFacingErrors: Error {
    case initalizationFailed
    case synchronizerError(canRetry: Bool)
    case connectionFailed
    case transactionSubmissionError
    case internalError
    case criticalError
}


