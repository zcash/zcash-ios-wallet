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
    @Published var sendZecAmount: Double
    @Published var sendZecAmountText: String = "0"
    @Published var showReceiveFunds: Bool
    @Published var showProfile: Bool
    @Published var verifiedBalance: Double
    @Published var isSyncing: Bool = false
    var sendingPushed: Bool = false
    @Published var zAddress = ""
    @Published var balance: Double = 0
    @Published var progress: Float = 0
    var pendingTransactions: [DetailModel] = []
    private var cancellable = [AnyCancellable]()
    init(amount: Double = 0, balance: Double = 0) {
        verifiedBalance = balance
        sendZecAmount = amount
        showProfile = false
        showReceiveFunds = false
        let environment = ZECCWalletEnvironment.shared
        
        environment.synchronizer.verifiedBalance.receive(on: DispatchQueue.main)
                .sink(receiveValue: {
                    self.verifiedBalance = $0
                })
            .store(in: &cancellable)
        
        environment.synchronizer.balance.receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.balance = $0
            })
            .store(in: &cancellable)
        environment.synchronizer.progress.receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.progress = $0
            })
            .store(in: &cancellable)
        zAddress = ""
        
        NotificationCenter.default.publisher(for: .qrZaddressScanned)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print("error scanning: \(error)")
                case .finished:
                    print("finished scanning")
                }
            }) { (notification) in
                guard let address = notification.userInfo?["zAddress"] as? String else {
                    return
                }
                self.showReceiveFunds = false
                print("got address \(address)")
                self.zAddress = address
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
    }
    
    deinit {
        cancellable.forEach{ $0.cancel() }
    }
}

struct Home: View {
    
    var keypad: KeyPad
    @State var sendingPushed = false
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    
    var isSendingEnabled: Bool {
        $viewModel.verifiedBalance.wrappedValue > 0
    }
    
    var disposables: Set<AnyCancellable> = []
    
    init(amount: Double, verifiedBalance: Double) {
        self.viewModel = HomeViewModel(amount: amount, balance: verifiedBalance)
        self.keypad = KeyPad()
        
        self.keypad.viewModel.$value.receive(on: DispatchQueue.main)
            .assign(to: \.sendZecAmount, on: viewModel)
            .store(in: &disposables)
        self.keypad.viewModel.$text.receive(on: DispatchQueue.main)
            .assign(to: \.sendZecAmountText, on: viewModel)
            .store(in: &disposables)
    }
    
    var syncingButton: some View {
        Button(action: {}) {
            Text("Syncing")
                
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 50)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.zAmberGradient2, lineWidth: 4)
            )
        }
    }
    
    var enterAddressButton: some View {
        Button(action: {
            self.sendingPushed = true
            
        }) {
            ZcashButton(color: Color.black, fill: Color.zYellow, text: "Enter Address")
                .frame(height: 58)
                .padding([.leading, .trailing], 40)
                .opacity(isAmountValid ? 1.0 : 0.3 ) // validate this
            
        }    .disabled(!isAmountValid)
    }
    
    var isAmountValid: Bool {
        self.$viewModel.sendZecAmount.wrappedValue > 0 && self.$viewModel.sendZecAmount.wrappedValue < self.$viewModel.verifiedBalance.wrappedValue
        
    }
    
    var balanceView: AnyView {
        if appEnvironment.initializer.getBalance() > 0 {
            return AnyView (
                BalanceDetail(availableZec: self.$viewModel.verifiedBalance.wrappedValue, status: appEnvironment.balanceStatus)
            )
        } else if viewModel.pendingTransactions.count > 0 {
            guard let model = self.viewModel.pendingTransactions.first else { return AnyView(EmptyView()) }
            
            return AnyView (
                DetailCard(model: model)
            )
        } else {
            return AnyView(
                ActionableMessage(message: "No Balance", actionText: "Fund Now", action: { self.viewModel.showReceiveFunds = true })
            )
        }
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
                    .opacity(self.isSendingEnabled ? 1.0 : 1.0)
                    .scaledToFit()
                
                if self.isSendingEnabled {
                    Spacer()
                    BalanceDetail(availableZec: self.$viewModel.verifiedBalance.wrappedValue, status: appEnvironment.balanceStatus)
                } else {
                    Spacer()
                    balanceView
                        .padding()
                }
                
                Spacer()
                
                self.keypad
                    .opacity(self.isSendingEnabled ? 1.0 : 0.3)
                    .disabled(!self.isSendingEnabled)
                    .padding()
                    .frame(minWidth: 0, maxWidth: 250, alignment: .center)
                
                Spacer()
                
                if self.$viewModel.isSyncing.wrappedValue {
                    self.syncingButton
                } else {
                    
                    self.enterAddressButton
                    
                    
                    NavigationLink(
                        destination: EnterRecipient().environmentObject(
                            SendFlowEnvironment(
                                amount: viewModel.sendZecAmount,
                                verifiedBalance: viewModel.verifiedBalance,
                                address: viewModel.zAddress,
                                isActive: $sendingPushed
                                
                            )
                        ), isActive: self.$sendingPushed
                    ) {
                        EmptyView()
                    }.isDetailLink(false)
                }
                
                Spacer()
                
                NavigationLink(
                    destination: WalletDetails()
                        .environmentObject(WalletDetailsViewModel())
                        .navigationBarTitle(Text(""), displayMode: .inline)
                ) {
                    HStack(alignment: .center, spacing: 10) {
                        Image("wallet_details_icon")
                        Text("Wallet Details")
                            .font(.headline)
                            .frame(height: 48)
                    }.accentColor(Color.zLightGray)
                }.isDetailLink(false)
                Spacer()
                
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button(action: {
                    self.viewModel.showReceiveFunds = true
                }) {
                    Image("QRCodeIcon")
                        .accessibility(label: Text("Receive Funds"))
                        .scaleEffect(0.5)
                }.disabled(viewModel.isSyncing)
                    .sheet(isPresented: $viewModel.showReceiveFunds){
                        ReceiveFunds(address: self.appEnvironment.initializer.getAddress() ?? "")
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
            .navigationBarTitle("", displayMode:  .inline)
            .sheet(isPresented: $viewModel.showProfile){
                ProfileScreen(zAddress: self.$viewModel.zAddress)
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
