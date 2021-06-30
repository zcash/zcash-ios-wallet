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
    func report(handledException: Error)
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
    case sendTransaction = "send.transaction"
    case balance
    case autoShieldNotice = "notice.autoshielding"
    
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
    case landingBackupSkipped1 = "landing.backup.skip.1"
    case landingBackupSkipped2 = "landing.backup.skip.2"
    case landingBackupSkipped3 = "landing.backup.skip.3"
    case showProfile = "home.profile"
    case receive = "home.scan"
    case receiveBack = "receive.back"
    case receiveScan = "receive.scan"
    case scanBack = "scan.back"
    case scanReceive = "scan.receive"
    case scanTorch = "scan.torch"
    case balanceDetail = "home.balance.detail"
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
    case sendFinalDetails = "send.final.details"
    case profileClose = "profile.close"
    case profileNuke = "profile.nuke"
    case profileBackup = "profile.backup"
    case copyAddress = "copy.address"
    case backgroundAppRefreshStart = "background.apprefresh.start"
    case backgroundAppRefreshEnd = "background.apprefresh.end"
    case backgroundProcessingStart = "background.processing.start"
    case backgroundProcessingEnd = "background.processing.end"
    case shieldFundsStart = "shield.funds.start"
    case shieldFundsEnd = "shield.funds.end"
    case acceptAutoShieldNotice = "shield.notice.accept"
}
enum LogEvent: Equatable {
    case screen(screen: Screen)
    case tap(action: Action)
    case error(severity: ErrorSeverity)
    case feedback
}

enum ErrorSeverity: String {
    case critical = "error.critical"
    case noncritical = "error.noncritical"
    case warning = "error.warning"
    
    static let messageKey = "message"
    static let underlyingError = "error"
}



class NullLogger: EventLogging {
    func report(handledException: Error) {
    }
    func track(_ event: LogEvent, properties: KeyValuePairs<String, String>) {}
}


#if ENABLE_LOGGING
import Mixpanel
import Bugsnag
class MixPanelLogger: EventLogging {
    
    struct TrackingEvent: Equatable {
        let event: LogEvent
        let properties: [String : String]?
        
        var description: String {
            "Event: \(event) - Properties: \(properties ?? [:])"
        }
    }
    /**
     Ideally use DeveloperFacingErrors error types to they print fine on bugsnag
     */
    func report(handledException: Error) {
        guard let error = handledException as? DeveloperFacingErrors else {
            return Bugsnag.notifyError(handledException)
        }
        Bugsnag.notifyError(error.asNSError)
    }
    
    func track(_ event: LogEvent, properties: KeyValuePairs<String, String>) {
 
        let eventProperties = Dictionary<String,String>(uniqueKeysWithValues: Array(properties))
        
        logSubject.send(TrackingEvent(event: event, properties: eventProperties))
    }
    
    var logSubject: PassthroughSubject<TrackingEvent, Never>
    
    
    private func logEvent(_ event: TrackingEvent) {
        logger.event("MockPanel - \(event)")
    }
    
    private func trackEvent(_ tracking: TrackingEvent) {
        guard !test  else {
            logEvent(tracking)
            return
        }
        
        switch tracking.event {
        case .screen(let screen):
            Mixpanel.mainInstance().track(event: screen.rawValue, properties: tracking.properties)
        case .tap(let action):
            Mixpanel.mainInstance().track(event: action.rawValue, properties: tracking.properties)
        case .error(let severity):
            Mixpanel.mainInstance().track(event: severity.rawValue, properties: tracking.properties)
        case .feedback:
            Mixpanel.mainInstance().track(event: "funnel.feedback.submitted.100", properties: tracking.properties)
        }
    }
    
    var synchronizerEvents = [AnyCancellable]()
    var scheduler = DispatchQueue.global()
    
    /// Attempts to log to console logger if true
    var test: Bool
    
    /**
     inits the Mixpanel logger
     Parameters:
      - Parameter token: the Mixpanel token
      - Parameter test: attempts to send the logs to the console instead if such logger is set up. No logs are sent to MixPanel
     */
    init(token: String, test: Bool = false) {
        self.test = test
        Mixpanel.initialize(token: token)
        logSubject = PassthroughSubject<TrackingEvent,Never>()
        
        logSubject.receive(on: scheduler)
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: scheduler)
            .sink { (event) in
                self.trackEvent(event)
        }
        .store(in: &synchronizerEvents)
    }
}

#endif
