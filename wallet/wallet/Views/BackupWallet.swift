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
    
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    let itemSpacing: CGFloat = 24
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 50
    
    @State var progress: Float = 0
    @State var showModal = false
    
    var body: some View {
        
        ZStack {
            
            ZcashBackground()
            VStack(alignment: .center, spacing: itemSpacing) {
                Spacer()
                VStack(spacing: itemSpacing){
                    ZcashLogo(fillStyle: LinearGradient.amberGradient)
                    
                    Text("feedback_walletbackupstatus")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .padding(.horizontal, 48)
                    
                    Text(String(format: NSLocalizedString("balance_syncing", comment: ""),"\(Int(self.progress * 100))"))
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding(.horizontal, 48)
                        .opacity(self.progress > 0 ? 1.0 : 0)
                        .onReceive(ZECCWalletEnvironment.shared.synchronizer.progress, perform: { progress in
                            self.progress = progress
                        })
                }
                .padding(0)
                Spacer()
                NavigationLink(destination: SeedBackup(proceedsToHome: true).environmentObject(appEnvironment)){
                    Text("button_backup")
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                        .frame(height: self.buttonHeight)
                }.isDetailLink(false)
                
                NavigationLink(destination:  FundsAtRisk().environmentObject(appEnvironment)) {
                    Text("button_skip")
                        .foregroundColor(Color.zDarkGray3)
                        .font(.system(size: 20))
                        .frame(height: buttonHeight)
                }.isDetailLink(false)
                
            }.padding([.horizontal, .bottom], 24)
            
            }.navigationBarBackButtonHidden(true)
        .onAppear() {
                tracker.track(.tap(action: .landingBackupWallet), properties: [:])
        }
    }
}

struct BackupWallet_Previews: PreviewProvider {
    static var previews: some View {
        BackupWallet().environmentObject(ZECCWalletEnvironment.shared)
    }
}
