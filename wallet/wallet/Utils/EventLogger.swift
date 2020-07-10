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
    case showProfile = "home.profile"
    case receive = "home.scan"
    case receiveBack = "receive.back"
    case receiveScan = "receive.scan"
    case scanBack = "scan.back"
    case scanReceive = "scan.receive"
    case scanTorch = "scan.torch"
    case homeSend = "home.send"
    case sendAddressNext = "send.address.next"
    case sendAddressDoneAddress = "send.address.done.address"
    case sendAddressDoneAmount = "send.address.done.amount"
    case sendAddressPaste = "send.address.paste"
    case sendAddressBack = "send.address.back"
    case sendAddressScan = "send.address.scan"
    case sendConfirmBack = "send.confirm.back"
    case sendConfirmNext = "send.confirm.next"
    case sendMemoInclude = "send.memo.include"
    case sendMemoExclude = "send.memo.exclude"
    case sendMemoSkip = "send.memo.skip"
    case sendMemoNext = "send.memo.next"
    case sendFinalExit = "send.final.exit"
    case sendFinalClose = "send.final.close"
    case profileClose = "profile.close"
    case profileNuke = "profile.nuke"
    case profileBackup = "profile.backup"
    case copyAddress = "copy.address"
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
    
    struct TrackingEvent: Equatable {
        let event: LogEvent
        let properties: [String : String]?
        
        var description: String {
            "Event: \(event) - Properties: \(properties ?? [:])"
        }
    }
    
    func track(_ event: LogEvent, properties: KeyValuePairs<String, String>) {
 
        let eventProperties = Dictionary<String,String>(uniqueKeysWithValues: Array(properties))
        
        logSubject.send(TrackingEvent(event: event, properties: eventProperties))
    }
    
    var logSubject: PassthroughSubject<TrackingEvent, Never>
    
    
    private func logEvetn(_ event: TrackingEvent) {
        logger.event("MockPanel - \(event)")
    }
    
    private func trackEvent(_ tracking: TrackingEvent) {
        
        switch tracking.event {
        case .screen(let screen):
            Mixpanel.mainInstance().track(event: screen.rawValue, properties: tracking.properties)
        case .tap(let action):
            Mixpanel.mainInstance().track(event: action.rawValue, properties: tracking.properties)
        }
    }
    
    var cancellables = [AnyCancellable]()
    var scheduler = DispatchQueue.global()
    init(token: String, test: Bool = false) {
        Mixpanel.initialize(token: token)
        logSubject = PassthroughSubject<TrackingEvent,Never>()
        
        logSubject.receive(on: scheduler)
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: scheduler)
            .sink { (event) in
                self.trackEvent(event)
        }
        .store(in: &cancellables)
    }
}

#endif
