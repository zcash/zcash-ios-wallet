//
//  Home.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import ZcashLightClientKit
final class HomeViewModel: ObservableObject {
    var isFirstAppear = true
    let genericErrorMessage = "An error ocurred, please check your device logs"
    @Published var sendZecAmount: Double
    @Published var sendZecAmountText: String = "0"
    @Published var showReceiveFunds: Bool
    @Published var showProfile: Bool
    @Published var isSyncing: Bool = false
    var sendingPushed: Bool = false
    @Published var showError: Bool = false
    var lastError:  ZECCWalletEnvironment.WalletError?
    @Published var zAddress = ""
    @Published var balance: Double = 0
    var progress = CurrentValueSubject<Float,Never>(0)
    var pendingTransactions: [DetailModel] = []
    private var cancellable = [AnyCancellable]()
    var view: Home? {
        didSet {
            guard let home = view else { return }
            home.keypad.viewModel.$value.receive(on: DispatchQueue.main)
                .assign(to: \.sendZecAmount, on: self)
                .store(in: &cancellable)
            home.keypad.viewModel.$text.receive(on: DispatchQueue.main)
                .assign(to: \.sendZecAmountText, on: self)
                .store(in: &cancellable)
            
        }
    }
    init(amount: Double = 0, balance: Double = 0) {
        //        verifiedBalance = balance
        sendZecAmount = amount
        showProfile = false
        showReceiveFunds = false
        let environment = ZECCWalletEnvironment.shared
        
        //        environment.synchronizer.verifiedBalance.receive(on: DispatchQueue.main)
        //            .sink(receiveValue: {
        //                self.verifiedBalance = $0
        //            })
        //            .store(in: &cancellable)
        
        environment.synchronizer.balance.receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.balance = $0
            })
            .store(in: &cancellable)
        environment.synchronizer.progress.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                guard let self = self else { return }
                self.isSyncing = false
                self.progress.send(0)
                }, receiveValue: { [weak self] in
                    guard let self = self else { return }
                    self.isSyncing = $0 < 1.0 && $0 > 0
                    self.progress.send($0)
            })
            .store(in: &cancellable)
        
        environment.synchronizer.error.receive(on: DispatchQueue.main)
            .map( ZECCWalletEnvironment.mapError )
            .sink { [weak self] error in
                guard let self = self else { return }
                self.show(error: error)
        }
        .store(in: &cancellable)
        
        zAddress = ""
        
        NotificationCenter.default.publisher(for: .qrZaddressScanned)
            .receive(on: DispatchQueue.main)
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    logger.error("error scanning: \(error)")
                case .finished:
                    logger.debug("finished scanning")
                }
            }) { (notification) in
                guard let address = notification.userInfo?["zAddress"] as? String else {
                    return
                }
                self.showReceiveFunds = false
                logger.debug("got address \(address)")
                self.zAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
                DispatchQueue.main.async {
                    self.sendingPushed = true
                }
        }
        .store(in: &cancellable)
        
        environment.synchronizer.pendingTransactions.sink(receiveCompletion: { (completion) in
            
        }) { [weak self] (pendingTransactions) in
            self?.pendingTransactions = pendingTransactions.filter({ $0.minedHeight == BlockHeight.unmined && $0.errorCode == nil })
                .map( { DetailModel(pendingTransaction: $0)})
        }.store(in: &cancellable)
        environment.synchronizer.status.sink(receiveValue: { [weak self] status in
            
            guard let self = self else { return }
            switch status {
            case .syncing:
                self.isSyncing = true
            default:
                self.isSyncing = false
            }
        }).store(in: &cancellable)
        
        NotificationCenter.default.publisher(for: .sendFlowClosed).sink(receiveValue: { _ in
            self.view?.keypad.viewModel.clear()
        }
        ).store(in: &cancellable)
    }
    
    deinit {
        cancellable.forEach{ $0.cancel() }
    }
    
    func show(error: ZECCWalletEnvironment.WalletError) {
        self.lastError = error
        self.showError = true
    }
    
    func clearError() {
        self.lastError = nil
        self.showError = false
    }
    
    var errorAlert: Alert {
        let errorAction = {
            self.clearError()
        }
        
        guard let error = lastError else {
            return Alert(title: Text("Error"), message: Text(genericErrorMessage), dismissButton: .default(Text("dismiss"),action: errorAction))
        }
        
        var message = genericErrorMessage
        switch error {
        case .createFailed:
            message = "There was an error creating your wallet. Please back it up and try again"
        case .genericError(let genericMessage):
            message = genericMessage
        case .initializationFailed(let errMsg):
            message = errMsg
        case .connectionFailed(let connMsg):
            message = connMsg
        case .maxRetriesReached(attempts: let attempts):
            return Alert(
                title: Text("Error"),
                message: Text("Max Retry attempts (\(attempts)) have been reached"),
                primaryButton: .default(Text("dismiss"),action: errorAction),
                secondaryButton: .default(Text("Retry"),
                                          action: { ZECCWalletEnvironment.shared.synchronizer.start(retry: true )}
                )
            )
        }
        return Alert(
            title: Text("Error"),
            message: Text(message), dismissButton: .default(Text("dismiss"),action: errorAction))
    }
}

struct Home: View {
    let buttonHeight: CGFloat = 64
    let buttonPadding: CGFloat = 40
    var keypad: KeyPad
    @State var sendingPushed = false
    @State var showPending = true
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    
    var syncingButton: SyncingButton
    var disposables: Set<AnyCancellable> = []
    
    init(amount: Double, verifiedBalance: Double) {
        self.viewModel = HomeViewModel(amount: amount, balance: verifiedBalance)
        self.keypad = KeyPad()
        self.syncingButton = SyncingButton(progressSubject: ZECCWalletEnvironment.shared.synchronizer.progress)
        viewModel.view = self
    }
    
    var isSendingEnabled: Bool {
        appEnvironment.synchronizer.verifiedBalance.value > 0
    }
    
    var enterAddressButton: some View {
        Button(action: {
            self.sendingPushed = true
            
        }) {
            Text("Send")
                .foregroundColor(.black)
                .zcashButtonBackground(shape: .rounded(fillStyle: .solid(color: Color.zYellow)))
                .frame(height: buttonHeight)
                .padding([.leading, .trailing], buttonPadding)
                .opacity(isAmountValid ? 1.0 : 0.3 ) // validate this
            
        }    .disabled(!isAmountValid)
    }
    
    var isAmountValid: Bool {
        self.$viewModel.sendZecAmount.wrappedValue > 0 && self.$viewModel.sendZecAmount.wrappedValue < appEnvironment.synchronizer.verifiedBalance.value
        
    }
    
    var balanceView: AnyView {
        if appEnvironment.initializer.getBalance() > 0 {
            return AnyView (
                BalanceDetail(availableZec: appEnvironment.synchronizer.verifiedBalance.value, status: appEnvironment.balanceStatus)
            )
        } else {
            return AnyView(
                ActionableMessage(message: "No Balance")
            )
        }
    }
    
    var walletDetails: some View {
        Text("Wallet History")
            .foregroundColor(.white)
            .font(.body)
            .opacity(0.6)
            .frame(height: 48)
    }
    
    var detailCard: AnyView {
        guard self.showPending, let model = self.viewModel.pendingTransactions.first else { return AnyView(EmptyView()) }
        
        return AnyView (
            DetailCard(model: model)
                .frame(height: 50)
                .padding(.horizontal, buttonPadding)
                .onTapGesture() {
                    self.showPending = false
            }
        )
    }
    
    var body: some View {
        ZStack {
            
            if self.isSendingEnabled {
                ZcashBackground(showGradient: self.isSendingEnabled)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(alignment: .center) {
                
                Spacer()
                SendZecView(zatoshi: self.$viewModel.sendZecAmountText)
                    .opacity(self.isSendingEnabled ? 1.0 : 0.3)
                    .scaledToFit()
                
                if self.isSendingEnabled {
                    Spacer()
                    BalanceDetail(availableZec: appEnvironment.synchronizer.verifiedBalance.value, status: appEnvironment.balanceStatus)
                } else {
                    Spacer()
                    self.balanceView.padding([.horizontal], self.buttonPadding)
                }
                
                Spacer()
                
                self.keypad
                    .frame(minWidth: 0, maxWidth: 250, alignment: .center)
                    .opacity(self.isSendingEnabled ? 1.0 : 0.3)
                    .disabled(!self.isSendingEnabled)
                    .padding()
                    .alert(isPresented: self.$viewModel.showError) {
                        self.viewModel.errorAlert
                }
                
                
                Spacer()
                
                if self.$viewModel.isSyncing.wrappedValue {
                    self.syncingButton
                        .frame(height: buttonHeight)
                        .padding(.horizontal, buttonPadding)
                } else {
                    
                    self.enterAddressButton
                    
                    NavigationLink(
                        destination: EnterRecipient().environmentObject(
                            SendFlowEnvironment(
                                amount: viewModel.sendZecAmount,
                                verifiedBalance: appEnvironment.synchronizer.verifiedBalance.value,
                                address: viewModel.zAddress,
                                isActive: $sendingPushed
                                
                            )
                        ), isActive: self.$sendingPushed
                    ) {
                        EmptyView()
                    }.isDetailLink(false)
                }
                
                Spacer()
                
                if viewModel.isSyncing {
                    walletDetails
                        .opacity(0.4)
                } else {
                    NavigationLink(
                        destination: WalletDetails()
                            .environmentObject(WalletDetailsViewModel())
                            .navigationBarTitle(Text(""), displayMode: .inline)
                    ) {
                        walletDetails
                    }.isDetailLink(false)
                }
                /// FIXME: fix pending transactions stuck
                //                if viewModel.pendingTransactions.count > 0 {
                //                    detailCard
                //                }
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button(action: {
                    self.viewModel.showReceiveFunds = true
                }) {
                    Image("QRCodeIcon")
                        .accessibility(label: Text("Receive Funds"))
                        .scaleEffect(0.5)
                }
                .sheet(isPresented: $viewModel.showReceiveFunds){
                    ReceiveFunds(address: self.appEnvironment.initializer.getAddress() ?? "",
                                 isShown:  self.$viewModel.showReceiveFunds)
                }
                , trailing:
                Button(action: {
                    self.viewModel.showProfile = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .imageScale(.large)
                        .opacity(0.6)
                        .accessibility(label: Text("Your Profile"))
                        .padding()
            })
            
            .navigationBarTitle("", displayMode: .inline)
            .sheet(isPresented: $viewModel.showProfile){
                ProfileScreen(isShown: self.$viewModel.showProfile)
                    .environmentObject(self.appEnvironment)
                
        }
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Home(amount: 1.2345, verifiedBalance: 1.2345).environmentObject(ZECCWalletEnvironment.shared)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
            
            Home(amount: 1.2345, verifiedBalance: 1.2345).environmentObject(ZECCWalletEnvironment.shared)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            Home(amount: 1.2345, verifiedBalance: 1.2345).environmentObject(ZECCWalletEnvironment.shared)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
    }
}

extension BlockHeight {
    static var unmined: BlockHeight {
        -1
    }
}
