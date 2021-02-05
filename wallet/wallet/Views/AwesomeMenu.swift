//
//  AwesomeMenu.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 1/26/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import ZcashLightClientKit

import TinyQRScanner
final class AwesomeViewModel: ObservableObject {
    
    
    enum Status {
        
        case idle
        case shielding
        case failed(error: Error)
        case finished
    }
    @Published var status: Status = .idle
    @Published var unshieldedBalance: UnshieldedBalance = TransparentBalance.zero
    @Published var alertType: AwesomeMenu.AlertType? = nil
    @Binding var isActive: Bool
    var appEnvironment = ZECCWalletEnvironment.shared
    var shieldEnvironment = ShieldFlow.current
    var cancellables = [AnyCancellable]()
    var tAddress: String
    var chips: [String]
    var qrImage: CGImage?
    var lottie = LottieAnimation(filename: "lottie_shield")
    init(isActive: Binding<Bool>) {
        self._isActive = isActive
        var tAddr: String!
        
        do {
            let p = try SeedManager.default.exportPhrase()
            let s = try MnemonicSeedProvider.default.toSeed(mnemonic: p)
            tAddr = try DerivationTool.default.deriveTransparentAddress(seed: s)
            
        } catch {
            logger.error("unable to derive transaparent address from seed \(error)")
            tAddr = ""
        }
        self.tAddress = tAddr
        self.chips = tAddr.slice(into: 2)
        
        self.qrImage = QRCodeGenerator.generate(from: tAddr)
        
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
        
        self.shieldEnvironment.unshieldedBalance.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.unshieldedBalance = value
            })
            .store(in: &cancellables)

    }
    
    var isShieldingButtonEnabled: Bool {
        switch status {
        case .idle:
            return unshieldedBalance.confirmed >= ZcashSDK.shieldingThreshold
        default:
            return false
        }
    }
    func shieldConfirmedFunds() {
        
        self.shieldEnvironment.shield()
    }
}

struct TransparentBalance: UnshieldedBalance{
    var confirmed: Int64
    var unconfirmed: Int64
    
    static var zero: TransparentBalance {
        TransparentBalance(confirmed: 0, unconfirmed: 0)
    }
}

struct AwesomeMenu: View {
    
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
    
    
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    @EnvironmentObject var viewModel: AwesomeViewModel
    
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 20) {
                
                if case AwesomeViewModel.Status.shielding = self.viewModel.status {
                    Text("Shielding")
                        .foregroundColor(.white)
                        .font(.title)
                    Text("Do not close this screen")
                        .foregroundColor(.white)
                        .font(.caption)
                        .opacity(0.6)
                    self.viewModel.lottie
                        .onAppear() {
                            self.viewModel.lottie.play(loop: true)
                        }
                } else {
                    
               
                Text("Your Transparent Address")
                    .foregroundColor(.white)
                    .font(.title)
                
                if let img = self.viewModel.qrImage {
                    QRCodeContainer(qrImage: Image(img, scale: 1, label: Text(String(format:NSLocalizedString("QR Code for %@", comment: ""),self.viewModel.tAddress) )),
                                    badge: Image("t-zcash-badge"))
                        .frame(width: 200, height: 200, alignment: .center)
                        .layoutPriority(1)
                }
                
                Button(action: {
                    PasteboardAlertHelper.shared.copyToPasteBoard(value: self.viewModel.tAddress, notify: "feedback_addresscopied".localized())
                    logger.debug("address copied to clipboard")
             
                    tracker.track(.tap(action: .copyAddress), properties: [:])
                }) {
                    VStack {
                        AddressFragment(number: 1, word: self.viewModel.chips[0])
                        AddressFragment(number: 2, word: self.viewModel.chips[1])
                    }
                }
                .frame(height: 48)
                
                Spacer()
                Text("""
                        Balance:
                            Confirmed: \(self.viewModel.unshieldedBalance.confirmed.asHumanReadableZecBalance())
                            Unconfirmed: \(self.viewModel.unshieldedBalance.unconfirmed.asHumanReadableZecBalance())
                    """)
                    .foregroundColor(.white)
            
                Spacer()
                Button(action: {
                    self.viewModel.shieldConfirmedFunds()
                }) {
                    Text("Shield Confirmed Transparent Funds")
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: .zButtonGradient)))
                        .frame(height: 48)
                }
                .disabled(!viewModel.isShieldingButtonEnabled)
                .opacity(viewModel.isShieldingButtonEnabled ? 1.0 : 0.4)
                }
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 30)
        }
        .alert(item: self.$viewModel.alertType) { (p) -> Alert in
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
        .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
            self.viewModel.alertType = AlertType.pasteBoardItem(item: p)
        }
        .navigationBarTitle(Text("🛡Fund Guardian🛡"))
        .onAppear() {
 
        }
        .onDisappear() {
            ShieldFlow.endFlow()
        }
        
    }
    func closeThisAwesomeThing() {
        ShieldFlow.endFlow()
        self.viewModel.isActive = false
    }
}

struct AwesomeMenu_Previews: PreviewProvider {
    static var previews: some View {
        AwesomeMenu()
    }
}
