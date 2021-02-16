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
    var sendZecAmount: Double {
        zecAmountFormatter.number(from: sendZecAmountText)?.doubleValue ?? 0.0
    }
    @Published var sendZecAmountText: String = "0"
    @Published var showReceiveFunds: Bool
    @Published var showProfile: Bool
    @Published var isSyncing: Bool = false
    @Published var sendingPushed: Bool = false
    @Published var showError: Bool = false
    @Published var showHistory = false
    var lastError: UserFacingErrors?
    @Published var balance: Double = 0
    var progress = CurrentValueSubject<Float,Never>(0)
    var pendingTransactions: [DetailModel] = []
    private var cancellable = [AnyCancellable]()
    private var environmentCancellables = [AnyCancellable]()
    private var zecAmountFormatter = NumberFormatter.zecAmountFormatter
    init(amount: Double = 0, balance: Double = 0) {
        showProfile = false
        showReceiveFunds = false
        bindToEnvironmentEvents()
        
        NotificationCenter.default.publisher(for: .sendFlowStarted)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.unbindSubcribedEnvironmentEvents()
            }
        ).store(in: &cancellable)
        
        NotificationCenter.default.publisher(for: .sendFlowClosed)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.sendZecAmountText = ""
                self?.sendingPushed = false
                self?.bindToEnvironmentEvents()
            }
        ).store(in: &cancellable)
    }
    
    func bindToEnvironmentEvents() {
        let environment = ZECCWalletEnvironment.shared
        
        environment.synchronizer.balance
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.balance = $0
            })
            .store(in: &environmentCancellables)
        environment.synchronizer.progress
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                guard let self = self else { return }
                self.isSyncing = false
                self.progress.send(0)
                }, receiveValue: { [weak self] in
                    guard let self = self else { return }
                    self.isSyncing = $0 < 1.0 && $0 > 0
                    self.progress.send($0)
            })
            .store(in: &environmentCancellables)
        
        environment.synchronizer.errorPublisher
            .receive(on: DispatchQueue.main)
            .map( ZECCWalletEnvironment.mapError )
            .map(trackError)
            .map(mapToUserFacingError)
            .sink { [weak self] error in
                guard let self = self else { return }
                
                self.show(error: error)
        }
        .store(in: &environmentCancellables)
        
        
        environment.synchronizer.pendingTransactions
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
            
        }) { [weak self] (pendingTransactions) in
            self?.pendingTransactions = pendingTransactions.filter({ $0.minedHeight == BlockHeight.unmined && $0.errorCode == nil })
                .map( { DetailModel(pendingTransaction: $0)})
        }.store(in: &cancellable)
        environment.synchronizer.status
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] status in
            
            guard let self = self else { return }
            switch status {
            case .syncing:
                self.isSyncing = true
            default:
                self.isSyncing = false
            }
        }).store(in: &environmentCancellables)
       
    }
    
    func unbindSubcribedEnvironmentEvents() {
        environmentCancellables.forEach { $0.cancel() }
        environmentCancellables.removeAll()
    }
    
    deinit {
        unbindSubcribedEnvironmentEvents()
        cancellable.forEach { $0.cancel() }
    }
    
    func show(error: UserFacingErrors) {
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
            return Alert(title: Text("Error"), message: Text(genericErrorMessage), dismissButton: .default(Text("button_close"),action: errorAction))
        }
        
        
        let defaultAlert = Alert(title: Text(error.title),
                                message: Text(error.message),
                                dismissButton: .default(Text("button_close"),
                                                    action: errorAction))
        switch error {
        case .synchronizerError(let canRetry):
            if canRetry {
                return Alert(
                        title: Text(error.title),
                        message: Text(error.message),
                        primaryButton: .default(Text("button_close"),action: errorAction),
                        secondaryButton: .default(Text("Retry"),
                                                     action: {
                                                        self.clearError()
                                                        try? ZECCWalletEnvironment.shared.synchronizer.start(retry: true)
                                                        })
                           )
            } else {
                return defaultAlert
            }
        default:
            return defaultAlert
        }
    }
}

struct Home: View {
    let buttonHeight: CGFloat = 64
    let buttonPadding: CGFloat = 40
    @State var sendingPushed = false
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    var syncingButton: SyncingButton
    
    init(amount: Double, verifiedBalance: Double) {
        self.syncingButton = SyncingButton(progressSubject: ZECCWalletEnvironment.shared.synchronizer.progress)
    }
    
    var isSendingEnabled: Bool {
        appEnvironment.synchronizer.status.value != .syncing && appEnvironment.synchronizer.verifiedBalance.value > 0
    }
    
    func startSendFlow() {
        SendFlow.start(appEnviroment: appEnvironment,
                       isActive: self.$sendingPushed,
                       amount: viewModel.sendZecAmount)
        self.sendingPushed = true
    }
    
    func endSendFlow() {
        SendFlow.end()
        self.sendingPushed = false
    }
    
    var enterAddressButton: some View {
        Button(action: {
            tracker.track(.tap(action: .homeSend), properties: [:])
            self.startSendFlow()
        }) {
            Text("button_send")
                .foregroundColor(.black)
                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: Color.zYellow)))
                .frame(height: buttonHeight)
                .padding([.leading, .trailing], buttonPadding)
                .opacity(isSendingEnabled ? 1.0 : 0.3 ) // validate this
            
        }.disabled(!isSendingEnabled)
    }
    
    var isAmountValid: Bool {
        self.viewModel.sendZecAmount > 0 && self.viewModel.sendZecAmount < appEnvironment.synchronizer.verifiedBalance.value
        
    }
    
    var balanceView: AnyView {
        if appEnvironment.initializer.getBalance() > 0 {
            return AnyView (
                BalanceDetail(availableZec: appEnvironment.synchronizer.verifiedBalance.value, status: appEnvironment.balanceStatus)
            )
        } else {
            return AnyView(
                ActionableMessage(message: "balance_nofunds".localized())
            )
        }
    }
    
    var walletDetails: some View {
        Button(action: {
            self.viewModel.showHistory = true
        }, label: {
            Text("button_wallethistory")
                .foregroundColor(.white)
                .font(.body)
                .opacity(0.6)
                .frame(height: 48)
        })
    }
    
    var amountOpacity: Double {
        self.isSendingEnabled ? self.viewModel.sendZecAmount > 0 ? 1.0 : 0.6 : 0.3
    }
    
    var body: some View {
        ZStack {
            
            if self.isSendingEnabled {
                ZcashBackground(showGradient: self.isSendingEnabled)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(alignment: .center, spacing: 5) {
                
                ZcashNavigationBar(
                    leadingItem: {
                        Button(action: {
                            self.viewModel.showReceiveFunds = true
                            tracker.track(.tap(action: .receive), properties: [:])
                        }) {
                            Image("QRCodeIcon")
                                .renderingMode(.original)
                                .accessibility(label: Text("Receive Funds"))
                                .scaleEffect(0.5)
                            
                        }
                        .sheet(isPresented: $viewModel.showReceiveFunds){
                            ReceiveFunds(address: self.appEnvironment.initializer.getAddress() ?? "",
                                         isShown:  self.$viewModel.showReceiveFunds)
                                .environmentObject(self.appEnvironment)
                        }
                },
                    headerItem: {
                        Text("balance_amounttosend")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .opacity(self.isSendingEnabled ? 1 : 0.4)
                },
                    trailingItem: {
                        Button(action: {
                            tracker.track(.tap(action: .showProfile), properties: [:])
                            self.viewModel.showProfile = true
                        }) {
                            Image("person_pin-24px")
                                .renderingMode(.original)
                                .opacity(0.6)
                                .accessibility(label: Text("Your Profile"))
                                .padding()
                        }
                        .sheet(isPresented: $viewModel.showProfile){
                            ProfileScreen(isShown: self.$viewModel.showProfile)
                                .environmentObject(self.appEnvironment)
                        }
                })
                    .frame(height: 64)
                
                
                SendZecView(zatoshi: self.$viewModel.sendZecAmountText)
                    .opacity(amountOpacity)
                    .scaledToFit()
                
                if self.isSendingEnabled {
                  
                    BalanceDetail(availableZec: appEnvironment.synchronizer.verifiedBalance.value, status: appEnvironment.balanceStatus)
                } else {
                    Spacer()
                    self.balanceView.padding([.horizontal], self.buttonPadding)
                }
                
                Spacer()
                
                KeyPad(value: $viewModel.sendZecAmountText)
                    .frame(alignment: .center)
                    .padding(.horizontal, buttonPadding)
                    .opacity(self.isSendingEnabled ? 1.0 : 0.3)
                    .disabled(!self.isSendingEnabled)
                    .alert(isPresented: self.$viewModel.showError) {
                        self.viewModel.errorAlert
                }
                
                Spacer()
                
                if self.$viewModel.isSyncing.wrappedValue {
                    self.syncingButton
                        .frame(height: buttonHeight)
                        .padding(.horizontal, buttonPadding)
                } else {
                    
                    self.enterAddressButton.onReceive(self.viewModel.$sendingPushed) { pushed in
                        if pushed {
                            self.startSendFlow()
                        } else {
                            self.endSendFlow()
                        }
                    }
                    .disabled(!isAmountValid)
                    .opacity(isAmountValid ? 1 : 0.6)
                    
                    NavigationLink(
                        destination: LazyView(
                            SendTransaction()
                                .environmentObject(
                                    SendFlow.current! //fixme
                            )
                                .navigationBarTitle("",displayMode: .inline)
                                .navigationBarHidden(true)
                        ), isActive: self.$sendingPushed
                    ) {
                        EmptyView()
                    }.isDetailLink(false)
                }
                
               
                    NavigationLink(
                        destination:
                            LazyView(WalletDetails(isActive: self.$viewModel.showHistory)
                            .environmentObject(WalletDetailsViewModel())
                            .navigationBarTitle(Text(""), displayMode: .inline)
                            .navigationBarHidden(true))
                        
                        ,isActive: self.$viewModel.showHistory) {
                        walletDetails
                    }.isDetailLink(false)
                        .opacity(viewModel.isSyncing ? 0.4 : 1.0)
                        .disabled(viewModel.isSyncing)
                
            }
            .padding([.bottom], 20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear {
            tracker.track(.screen(screen: .home), properties: [:])
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
