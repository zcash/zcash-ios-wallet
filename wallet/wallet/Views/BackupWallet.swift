//
//  BackupWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct BackupWallet: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    let itemSpacing: CGFloat = 24
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 50
    
    @State private var showModal: Bool = false
    
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
                Spacer()
                NavigationLink(destination: SeedBackup(proceedsToHome: true).environmentObject(appEnvironment)){
                    Text("Backup Wallet")
                               .font(.system(size: 17))
                               .foregroundColor(Color.black)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                               
                    .frame(height: self.buttonHeight)
                    .padding([.leading, .trailing], self.buttonPadding)
                }
                .padding([.leading, .trailing], buttonPadding)
                
                
                NavigationLink(destination:  Home(amount: 0, verifiedBalance: appEnvironment.initializer.getBalance().asHumanReadableZecBalance()).environmentObject(appEnvironment)) {
                    Text("Skip")
                        .foregroundColor(Color.zDarkGray3)
                        .font(.system(size: 17))
                        .frame(height: buttonHeight)
                }
                .padding([.leading, .trailing], buttonPadding)
                Spacer()
            }
        }
        .onAppear() {
            do {
                try self.appEnvironment.createNewWallet()
            } catch {
                print("could not create new wallet: \(error)")
            }
        }
       
    }
}

struct BackupWallet_Previews: PreviewProvider {
    static var previews: some View {
        BackupWallet().environmentObject(ZECCWalletEnvironment.shared)
    }
}
