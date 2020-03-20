//
//  BackupWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
struct BackupWallet: View {
    
    class BackupWalletViewModel: ObservableObject {
        var showModal: Bool = false
        var progress: Int = 0
        
        var disposables = [AnyCancellable]()
        init() {}
        
        func bindSync() {
            ZECCWalletEnvironment.shared.synchronizer.progress
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { self.progress =  Int($0 * 100)})
            .store(in: &disposables)
        }
        deinit {
            disposables.forEach({ $0.cancel() })
        }
    }
    
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @ObservedObject var viewModel =  BackupWalletViewModel()
    let itemSpacing: CGFloat = 24
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 50
    
    
    var body: some View {
        
        ZStack {
            
            ZcashBackground()
            VStack(alignment: .center, spacing: itemSpacing) {
                Spacer()
                ZcashLogo()
                
                Text("Your Wallet needs\nto be Backed up")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .padding(.horizontal, 48)
                
                Text("Syncing \($viewModel.progress.wrappedValue)%")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .padding(.horizontal, 48)
                    .opacity(0) //TODO: fix this
                
                Spacer()
                
                NavigationLink(destination: SeedBackup(proceedsToHome: true).environmentObject(appEnvironment)){
                    Text("Backup Wallet")
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                        .frame(height: self.buttonHeight)
                }.isDetailLink(false)
                
                NavigationLink(destination:  FundsAtRisk().environmentObject(appEnvironment)) {
                    Text("Skip")
                        .foregroundColor(Color.zDarkGray3)
                        .font(.system(size: 20))
                        .frame(height: buttonHeight)
                }.isDetailLink(false)
                
            }.padding([.horizontal, .bottom], 24)
            
            }.navigationBarBackButtonHidden(true)
        .onAppear() {
            do {
                try self.appEnvironment.createNewWallet()
                self.viewModel.bindSync()
            } catch {
                logger.error("could not create new wallet: \(error)")
            }
        }
        
    }
}

struct BackupWallet_Previews: PreviewProvider {
    static var previews: some View {
        BackupWallet().environmentObject(ZECCWalletEnvironment.shared)
    }
}
