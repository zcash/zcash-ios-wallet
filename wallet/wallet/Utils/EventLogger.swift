//
//  EventLogger.swift
//  wallet
//
//  Created by Francisco Gindre on 7/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine

protocol EventLogging {
    func track(_ event: LogEvent, properties: KeyValuePairs<String, String>)
}


enum Screen: String {
    case backup
    case home
    case history = "wallet.detail"
    case landing
    case profile
    case feedback
    case receive
    case restore
    case scan
    case sendAddress = "send.address"
    case sendConfirm = "send.confirm"
    case sendFinal = "send.final"
    case sendMemo = "send.memo"
    
}
enum Action: String {
    case backupDone = "backup.done"
    case backupVerify = "backup.verify"
    case walletPrompt = "landing.devwallet.prompt"
    case walletImport = "landing.devwallet.import"
    case walletCancel = "landing.devwallet.cancel"
    case ladingRestoreWallet = "landing.restore"
    case landingCreateNew = "landing.new"
    case landingBackupWallet = "landing.backup"
}
enum LogEvent: Equatable {
    case screen(screen: Screen)
    case tap(action: Action)
}



class NullLogger: EventLogging {
    func track(_ event: LogEvent, properties: KeyValuePairs<String, String>) {}
}


#if ENABLE_LOGGING
import Mixpanel
class MixPanelLogger: EventLogging {
    func track(_ event: LogEvent, properties: KeyValuePairs<String, String>) {
        
        
        let eventProperties = Dictionary<String,String>(uniqueKeysWithValues: Array(properties))
        switch event {
        case .screen(let screen):
            logEvent(screen.rawValue, properties: eventProperties)
        case .tap(let action):
            logEvent(action.rawValue, properties: eventProperties)
        }
    }
    
    var logSubject: PassthroughSubject<LogEvent, Never>
    
    
    private func logEvent(_ name: String, properties: [String : String]? = nil ) {
        Mixpanel.mainInstance().track(event: name, properties: properties)
    }
    
    var cancellables = [AnyCancellable]()
    var scheduler = DispatchQueue.global()
    init(token: String) {
        Mixpanel.initialize(token: token)
        logSubject = PassthroughSubject<LogEvent,Never>()
        
        logSubject.receive(on: scheduler)
        .removeDuplicates()
            .debounce(for: 0.3, scheduler: scheduler)
            .sink { (event) in
                self.logEvent("")
            }
            .store(in: &cancellables)
    }
}

#endif
