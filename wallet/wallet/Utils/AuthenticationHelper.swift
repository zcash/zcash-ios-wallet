//
//  AuthenticationHelper.swift
//  wallet
//
//  Created by Francisco Gindre on 7/29/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import LocalAuthentication
import Combine

enum AuthenticationEvent {
    case success
    case userDeclined
    case userFailed
    case failed(error: AuthenticationError)
}

enum AuthenticationError: Error {
    case authError(localAuthError: LAError)
    case generalError(message: String)
    case unknown
}
class AuthenticationHelper {
    
    #if targetEnvironment(simulator)
    static let authenticationPolicy = LAPolicy.deviceOwnerAuthentication
    #else
    static let authenticationPolicy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
    #endif
    static var authenticationPublisher =  PassthroughSubject<AuthenticationEvent,Never>()
    static func authenticate(with localizedReason: String) {
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(authenticationPolicy, error: &error) {
            // it's possible, so go ahead and use it
            
            context.evaluatePolicy(authenticationPolicy, localizedReason: localizedReason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        // authenticated successfully
                        authenticationPublisher.send(.success)
                    } else {
                        // there was a problem
                        guard let authError = authenticationError as? LAError else {
                            guard let e = authenticationError else {
                                authenticationPublisher.send(.failed(error:.unknown))
                                return
                            }
                            
                            authenticationPublisher.send(.failed(error: .generalError(message: e.localizedDescription)))
                            return
                        }
                        
                        switch authError.code {
                        case .passcodeNotSet:
                            authenticationPublisher.send(.success)
                        case .authenticationFailed:
                            authenticationPublisher.send(.userFailed)
                        case .userCancel:
                            authenticationPublisher.send(.userFailed)
                        default:
                            authenticationPublisher.send(.failed(error: .authError(localAuthError: authError)))
                        }
                    }
                }
            }
        } else {
            guard let authError = error as? LAError else {
                guard let e = error else {
                    //no error whatsoever
                    authenticationPublisher.send(.success)
                    return
                }
                authenticationPublisher.send(.failed(error:.generalError(message: e.localizedDescription)))
                
                return
            }
            authenticationPublisher.send(.failed(error: .generalError(message: authError.localizedDescription)))
            
        }
    }
}
