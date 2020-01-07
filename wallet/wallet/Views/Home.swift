//
//  Home.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    @Published var sendZecAmount: Double
    @Published var showReceiveFunds: Bool
    @Published var showProfile: Bool
    @Published var verifiedBalance: Double
    @Published var isSyncing: Bool = false
    
    init(amount: Double, balance: Double) {
        verifiedBalance = balance
        sendZecAmount = amount
        showProfile = false
        showReceiveFunds = false
    }
}

struct Home: View {
    
    var keypad: KeyPad
    @ObservedObject var viewModel: HomeViewModel
    
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
    }
    
    var syncingButton: some View {
        Button(action: {}) {
            Text("Syncing")
                
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 300, height: 50)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.zAmberGradient2, lineWidth: 4)
            )
        }
    }
    
    var enterAddressButton: some View {
       
        
        Button(action:{}) {
                ZcashButton(color: Color.black, fill: Color.zYellow, text: "Create New Wallet")
                .frame(height: 58)
                .padding([.leading, .trailing], 40)
        }
        .opacity(isAmountValid ? 1.0 : 0.3 ) // validate this
        .disabled(!isAmountValid)

    }
    
    var isAmountValid: Bool {
        self.$viewModel.sendZecAmount.wrappedValue > 0 && self.$viewModel.sendZecAmount.wrappedValue < self.$viewModel.verifiedBalance.wrappedValue
        
    }
    
    var body: some View {
        
        ZStack {
            
            if isSendingEnabled {
                Background(showGradient: self.isSendingEnabled)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(alignment: .center, spacing: 30) {
                
                SendZecView(zatoshi: $viewModel.sendZecAmount)
                    .opacity(isSendingEnabled ? 1.0 : 1.0)
                
                if isSendingEnabled {
                    BalanceDetail(availableZec: $viewModel.verifiedBalance.wrappedValue, status: .available)
                } else {
                    Spacer()
                    ActionableMessage(message: "No Balance", actionText: "Fund Now", action: {})
                        .padding()
                }
                Spacer()
                keypad
                    .opacity(isSendingEnabled ? 1.0 : 0.3)
                    .disabled($viewModel.verifiedBalance.wrappedValue <= 0)
                
                Spacer()
                
                if $viewModel.isSyncing.wrappedValue {
                    syncingButton
                } else {
                    enterAddressButton
                }
                
                Spacer()
                
                Button(action: {})  {
                    HStack(alignment: .center, spacing: 10) {
                        Image("wallet_details_icon")
                        Text("Wallet Details")
                            .font(.headline)
                    }.accentColor(Color.zLightGray)
                }
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
                }, trailing:
                Button(action: {
                    self.viewModel.showProfile = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .imageScale(.large)
                        .accessibility(label: Text("Your Profile"))
                        .padding()
            })
            .sheet(isPresented: $viewModel.showReceiveFunds){
                ReceiveFunds(address: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6")
                    .navigationBarHidden(false)
                    .navigationBarTitle("", displayMode: .inline)
        }
        
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(amount: 0, verifiedBalance: 0)
    }
}
