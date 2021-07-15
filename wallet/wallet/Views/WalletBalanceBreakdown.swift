//
//  WalletBalanceDetail.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 4/26/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import ZcashLightClientKit

final class WalletBalanceBreakdownViewModel: ObservableObject {
    
    enum Status {
        case idle
        case shielding
        case failed(error: Error)
        case finished(pendingTx: PendingTransactionEntity)
        var isShielding: Bool {
            switch self {
            case .shielding:
                return true
            default:
                return false
            }
        }
    }
    
    enum AlertType: Identifiable {
        case pasteBoardItem(item: PasteboardItemModel)
        case feedback(message: Text)
        case error(title: Text, message: Text)
        
        var id: Int {
            switch self {
            case .pasteBoardItem:
                return 0
            case .feedback:
                return 1
            case .error:
                return 2
            }
        }
    }
    
    @Published var status: Status = .idle
    @Published var transparentBalance = ReadableBalance.zero
    @Published var shieldedBalance = ReadableBalance.zero
    @Published var seeDetailsActive: DetailModel? = nil
    @Published var alertType: AlertType? = nil
    
    var unconfirmedFunds: Double {
        transparentBalance.unconfirmedFunds + shieldedBalance.unconfirmedFunds
    }
    var appEnvironment = ZECCWalletEnvironment.shared
    
    var cancellables = [AnyCancellable]()
    
    
    init() {
        self.appEnvironment.synchronizer.transparentBalance.receive(on: DispatchQueue.main)
            .map({ return ReadableBalance(walletBalance: $0)})
            .assign(to: \.transparentBalance , on: self)
            .store(in: &cancellables)
        
        self.appEnvironment.synchronizer.shieldedBalance.receive(on: DispatchQueue.main)
            .map({ return ReadableBalance(walletBalance: $0) })
            .assign(to: \.shieldedBalance , on: self)
            .store(in: &cancellables)
    }
    
    var isShieldingButtonEnabled: Bool {
        switch status {
        case .idle:
            return transparentBalance.verified >= ZcashSDK.shieldingThreshold.asHumanReadableZecBalance()
        default:
            return false
        }
    }
    
    func shieldConfirmedFunds() {
        self.status = .shielding
        
        do {
          let shieldEnvironment = try ShieldFlow.startWithShilderOrFail(AutoShieldingBuilder.manualShielder(keyProvider: DefaultShieldingKeyProvider(), shielder: appEnvironment.synchronizer.synchronizer))
        
        shieldEnvironment.status.receive(on: DispatchQueue.main)
            .sink { [weak self](completion) in
                guard let self = self else {
                    return
                }
                switch completion {
                case .finished:
                    
                    UserSettings.shared.userEverShielded = true
                    tracker.track(.tap(action: .shieldFundsEnd), properties: ["success" : "true"])
                    
                    
                case .failure(let error):
                    tracker.report(handledException: DeveloperFacingErrors.handledException(error: error))
                    tracker.track(.tap(action: .shieldFundsEnd), properties: ["success" : "false"])
                    self.status = .failed(error: error)
                    self.alertType = .error(title: Text("Error"), message: Text(error.localizedDescription))
                }
            } receiveValue: { [weak self](s) in
                guard let self = self else {
                    return
                }
                switch s {
                case .ended(let shieldingTx):
                    self.status = .finished(pendingTx: shieldingTx)
                case .notStarted, .notNeeded:
                    self.status = .idle
                case .shielding:
                    self.status = .shielding
                
                }
            }.store(in: &cancellables)
        
        shieldEnvironment.shield()
            
        } catch {
            self.status = .failed(error: error)
            tracker.report(handledException: DeveloperFacingErrors.handledException(error: error))
        }
    }
}

struct WalletBalanceBreakdown: View {
    @EnvironmentObject var model: WalletBalanceBreakdownViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.walletEnvironment) var appEnvironment
    @State var latestHeight: BlockHeight = ZECCWalletEnvironment.shared.synchronizer.syncBlockHeight.value
    
    @ViewBuilder func idleScreen() -> some View {
        VStack {
            VStack(alignment: .trailing, spacing: 2) {
                Text("Block: \(latestHeight)")
                    .onReceive(appEnvironment.synchronizer.syncBlockHeight, perform: { value in
                        latestHeight = value
                    })
                    .foregroundColor(.zLightGray)
                    .frame(alignment: .trailing)
                BalanceBreakdown(model: BalanceBreakdownViewModel(shielded: model.shieldedBalance, transparent: model.transparentBalance))
                    .frame(height: 270, alignment: .center)
                    .cornerRadius(5)
                Text("Auto Shielding Threshold: \(ZECCWalletEnvironment.thresholdInZec) \(.ZEC)")
                    .foregroundColor(.zLightGray)
                    .frame(alignment: .trailing)
                    .font(.caption)
            }.padding(0)
            Spacer()
            if model.unconfirmedFunds > 0 {
                Text("(\(model.unconfirmedFunds.toZecAmount()) \(.ZEC) pending)")
                    .foregroundColor(.zGray3)
                Spacer()
            }
            
            Button(action: {
                tracker.track(.tap(action: .shieldFundsStart), properties: [:])
                self.model.shieldConfirmedFunds()
            }) {
                Text("Shield Transparent Funds")
                    .foregroundColor(.black)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: .zButtonGradient)))
                    .frame(height: 48)
            }
            .disabled(!model.isShieldingButtonEnabled)
            .opacity(model.isShieldingButtonEnabled ? 1.0 : 0.4)
        }
        .padding([.horizontal, .vertical], 24)
        .zcashNavigationBar {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("Back")
                    .renderingMode(.original)
            }
        } headerItem: {
            EmptyView()
        } trailingItem: {
            EmptyView()
        }

    }

    @ViewBuilder func viewForState(_ state: WalletBalanceBreakdownViewModel.Status) -> some View {
        switch state {
        case .idle, .failed:
            idleScreen()
        case .shielding:
            AutoShieldView.shieldingScreen()
                .zcashNavigationBar {
                    EmptyView()
                } headerItem: {
                    EmptyView()
                } trailingItem: {
                    EmptyView()
                }
        case .finished(let shieldingTx):
            AutoShieldView.success(shieldingTx: DetailModel(pendingTransaction: shieldingTx)) {
                self.model.seeDetailsActive = DetailModel(pendingTransaction: shieldingTx)
            } dismissBlock: {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            ZcashBackground()
            viewForState(model.status)
        }
        .alert(item: self.$model.alertType) { (p) -> Alert in
            switch p {
            case .error(let title, let message):
                return Alert(title: title, message: message, dismissButton: .default(Text("Ok"), action: {
                    self.closeThisAwesomeThing()
                }))
            case .feedback(let message):
                return Alert(title: Text(""), message: message, dismissButton: .default(Text("Ok"), action: {
                    self.closeThisAwesomeThing()
                }))
            case .pasteBoardItem(let item):
                return PasteboardAlertHelper.alert(for: item)
            }
        }
        .sheet(item: self.$model.seeDetailsActive, content: { model in
            TxDetailsWrapper(row: model)
        })
        .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
            self.model.alertType = WalletBalanceBreakdownViewModel.AlertType.pasteBoardItem(item: p)
        }
        .onAppear() {
            tracker.track(.screen(screen: .balance), properties: [:])
        }
        .onDisappear() {
            ShieldFlow.endFlow()
            ModelFlyWeight.shared.dispose(flyweight: model)
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
    
    func closeThisAwesomeThing() {
        ShieldFlow.endFlow()
        presentationMode.wrappedValue.dismiss()
    }
    
}

struct WalletBalanceDetail_Previews: PreviewProvider {
    static var previews: some View {
        WalletBalanceBreakdown()
    }
}


extension ZECCWalletEnvironment {
    static var thresholdInZec: String {
        String(Double(ZECCWalletEnvironment.autoShieldingThresholdInZatoshi) / Double(ZcashSDK.ZATOSHI_PER_ZEC))
    }
}
