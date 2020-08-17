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
    @Published var sendingPushed: Bool = false
    @Published var showError: Bool = false
    var lastError:  UserFacingErrors?
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
                .map({ (amount) -> String in
                    amount.isEmpty ? "0" : amount
                })
                .assign(to: \.sendZecAmountText, on: self)
                .store(in: &cancellable)
            
        }
    }
    init(amount: Double = 0, balance: Double = 0) {
        sendZecAmount = amount
        showProfile = false
        showReceiveFunds = false
        let environment = ZECCWalletEnvironment.shared
        
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
        
        environment.synchronizer.errorPublisher.receive(on: DispatchQueue.main)
            .map( ZECCWalletEnvironment.mapError )
            .map(trackError)
            .map(mapToUserFacingError)
            .sink { [weak self] error in
                guard let self = self else { return }
                
                self.show(error: error)
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
        
        NotificationCenter.default.publisher(for: .sendFlowClosed)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                self.view?.keypad.viewModel.clear()
                self.sendingPushed = false
            }
        ).store(in: &cancellable)
    }
    
    deinit {
        cancellable.forEach{ $0.cancel() }
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
            return Alert(title: Text("Error"), message: Text(genericErrorMessage), dismissButton: .default(Text("dismiss"),action: errorAction))
        }
        
        
        let defaultAlert = Alert(title: Text(error.title),
                                message: Text(error.message),
                                dismissButton: .default(Text("dismiss"),
                                                    action: errorAction))
        switch error {
        case .synchronizerError(let canRetry):
            if canRetry {
                return Alert(
                        title: Text(error.title),
                        message: Text(error.message),
                        primaryButton: .default(Text("dismiss"),action: errorAction),
                        secondaryButton: .default(Text("Retry"),
                                                     action: {
                                                        self.clearError()
                                                        ZECCWalletEnvironment.shared.synchronizer.start(retry: true)
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
    var keypad: KeyPad
    @State var sendingPushed = false
    @State var showPending = true
    @State var showHistory = false
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
    
    func startSendFlow() {
        SendFlow.start(appEnviroment: appEnvironment,
                       isActive: self.$sendingPushed,
                       amount: viewModel.sendZecAmount)
        self.sendingPushed = true
    }
    
    func endSendFlow() {
        SendFlow.end()
    }
    
    var enterAddressButton: some View {
        Button(action: {
            tracker.track(.tap(action: .homeSend), properties: [:])
            self.startSendFlow()
        }) {
            Text("Send")
                .foregroundColor(.black)
                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: Color.zYellow)))
                .frame(height: buttonHeight)
                .padding([.leading, .trailing], buttonPadding)
                .opacity(isSendingEnabled ? 1.0 : 0.3 ) // validate this
            
        }    .disabled(!isSendingEnabled)
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
                ActionableMessage(message: "No Balance".localized())
            )
        }
    }
    
    var walletDetails: some View {
        Text("View History")
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
    
    var amountOpacity: Double {
        self.isSendingEnabled ? self.$viewModel.sendZecAmount.wrappedValue > 0 ? 1.0 : 0.6 : 0.3
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
                        Text("Enter an amount to send")
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
                
                self.keypad
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
                
                if viewModel.isSyncing {
                    //Warning: This exists for the purpose of not having a link in the screen while syncing. LazyLoading breaks the UITableView underneath list for some reason and refreshing wallet history polls the database which can't happen while syncing.
                    walletDetails
                        .opacity(0.4)
                } else {
                    NavigationLink(
                        destination:
                        WalletDetails(isActive: $showHistory)
                            .environmentObject(WalletDetailsViewModel())
                            .navigationBarTitle(Text(""), displayMode: .inline)
                            .navigationBarHidden(true)
                        
                    ,isActive: $showHistory) {
                        walletDetails
                    }.isDetailLink(false)
                }
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
