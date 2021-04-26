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
        case finished
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
    
    @Published var alertType: AlertType? = nil
    
    var unconfirmedFunds: Double {
        transparentBalance.unconfirmedFunds + shieldedBalance.unconfirmedFunds
    }
    var appEnvironment = ZECCWalletEnvironment.shared
    var shieldEnvironment = ShieldFlow.current
    var cancellables = [AnyCancellable]()
    
    var lottie = LottieAnimation(filename: "lottie_shield")
    init() {
        self.appEnvironment.synchronizer.transparentBalance.receive(on: DispatchQueue.main)
            .map({ return ReadableBalance(walletBalance: $0)})
            .assign(to: \.transparentBalance , on: self)
            .store(in: &cancellables)
        
        self.appEnvironment.synchronizer.shieldedBalance.receive(on: DispatchQueue.main)
            .map({ return ReadableBalance(walletBalance: $0) })
            .assign(to: \.shieldedBalance , on: self)
            .store(in: &cancellables)
        
        self.shieldEnvironment.status.receive(on: DispatchQueue.main)
            .sink { [weak self](completion) in
                guard let self = self else {
                    return
                }
                switch completion {
                case .finished:
                    
                    UserSettings.shared.userEverShielded = true
                    self.status = .finished
                    self.alertType = .feedback(message: Text("Your once transparent funds, are now being shielded!"))
                    
                case .failure(let error):
                    self.status = .failed(error: error)
                    self.alertType = .error(title: Text("Error"), message: Text(error.localizedDescription))
                }
            } receiveValue: { [weak self](s) in
                guard let self = self else {
                    return
                }
                switch s {
                case .ended:
                    self.status = .finished
                case .notStarted:
                    self.status = .idle
                case .shielding:
                    self.status = .shielding
                    
                }
            }.store(in: &cancellables)
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
        self.shieldEnvironment.shield()
    }
}

struct WalletBalanceBreakdown: View {
    @State var model = WalletBalanceBreakdownViewModel()
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack {
                BalanceBreakdown(model: BalanceBreakdownViewModel(shielded: model.shieldedBalance, transparent: model.transparentBalance))
                    .frame(height: 270, alignment: .center)
                    .cornerRadius(5)
                Spacer()
                if model.unconfirmedFunds > 0 {
                    Text("(\(model.unconfirmedFunds.toZecAmount()) ZEC pending")
                        .foregroundColor(.zGray3)
                    Spacer()
                }
                
                Text("Shield Transparent Funds")
                    .foregroundColor(.black)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: .zYellow)))
                    .frame(height: 48)
            }
            .padding([.horizontal, .vertical], 24)
            
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
    }
}

struct WalletBalanceDetail_Previews: PreviewProvider {
    static var previews: some View {
        WalletBalanceBreakdown()
    }
}
