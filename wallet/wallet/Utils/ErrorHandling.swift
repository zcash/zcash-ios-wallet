//
//  ErrorHandling.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

enum WalletError: Error {
    case createFailed(underlying: Error)
    case initializationFailed(message: String)
    case synchronizerFailed
    case genericErrorWithMessage(message: String)
    case genericErrorWithError(error: Error)
    case networkTimeout
    case connectionFailed
    case connectionFailedWithError(error: Error)
    case maxRetriesReached(attempts: Int)
    case sendFailed(error: Error)
    case criticalError(error: Error)
}

@discardableResult func trackError(_ walletError: WalletError) -> WalletError {
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
        return .initalizationFailed(underlyingError: walletError)
    case .initializationFailed:
        return .initalizationFailed(underlyingError: walletError)
    case .synchronizerFailed:
        return .synchronizerError(canRetry: false)
    case .genericErrorWithMessage(let message):
        return .internalErrorWithMessage(message: message)
    case .genericErrorWithError(let error):
        return .internalError(error: error)
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
    case .criticalError(let error):
        return .criticalError(error: error)
    }
}

enum UserFacingErrors: Error {
    case initalizationFailed(underlyingError: Error)
    case synchronizerError(canRetry: Bool)
    case connectionFailed
    case transactionSubmissionError
    case internalErrorWithMessage(message: String)
    case internalError(error: Error)
    case criticalError(error: Error?)
}

enum DeveloperFacingErrors: Error {
    case thisShouldntBeHappening(error: Error)
    case unexpectedBehavior(message: String)
    case programmingError(error: Error)
    case handledException(error: Error)
    
}

extension DeveloperFacingErrors {
    var asNSError: NSError {
        NSError(domain: self.domain, code: self.errorCode, userInfo: self.errorUserInfo)
    }
}

extension DeveloperFacingErrors: CustomNSError {
    var domain: String {
        switch self {
        case .handledException:
            return "DeveloperFacingErrors.handledException"
        case .thisShouldntBeHappening:
            return "DeveloperFacingErrors.thisShouldntBeHappening"
        case .unexpectedBehavior:
            return "DeveloperFacingErrors.unexpectedBehavior"
        case .programmingError:
            return "DeveloperFacingErrors.programmingError"
        }
    }
    
    var errorCode: Int {
        switch  self {
        case .thisShouldntBeHappening:
            return 0
        case .unexpectedBehavior:
            return 1
        case .programmingError:
            return 2
        case .handledException:
            return 3
        }
    }
    
    var underlyingError: Error {
        switch self {
        case .handledException(let error):
            return error
        case .programmingError(let error):
            return error
        case .thisShouldntBeHappening(let error):
            return error
        case .unexpectedBehavior:
            return self
        }
    }
    var errorUserInfo: [String : Any] {
        
        return [
            NSLocalizedDescriptionKey : self.localizedDescription,
            NSUnderlyingErrorKey : self.underlyingError,
            NSLocalizedFailureReasonErrorKey : self.localizedDescription,
        ]
    }
}

extension DeveloperFacingErrors: CustomStringConvertible {
    public var description: String {
        return self.localizedDescription
    }
    
    
    public var localizedDescription: String {
        switch self {
        case .programmingError(let error):
            return "This is probably a programming error. \(error). Description: \(error.localizedDescription)"
        case .unexpectedBehavior(let message):
            return "Unexpected Behavior - Message: \(message)"
        case .thisShouldntBeHappening(let error):
            return "Serious Error - This is something that shouldn't be happening. Probably indicates an inconsistent state or some logic problem that should be revised and corrected. Error: \(error). Description: \(error.localizedDescription)"
        case .handledException(let error):
            return "Handled Exception - This is an error that was handled in the app. Error: \(error). Description: \(error.localizedDescription)"
        }
    }
}
