//
//  CreateNewWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct CreateNewWallet: View {
   
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    let itemSpacing: CGFloat = 24
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 58
    var body: some View {
        
        
        ZStack {
            
            ZcashBackground()
            
            VStack(alignment: .center, spacing: self.itemSpacing) {
                Spacer()
                
                ZcashLogo()
                
                Spacer()
                NavigationLink(destination:
                    BackupWallet().environmentObject(appEnvironment)
                        .navigationBarHidden(true)
                    
                ) {
                    ZcashButton(color: Color.black, fill: Color.zYellow, text: "Create New Wallet")
                        .frame(height: self.buttonHeight)
                        .padding([.leading, .trailing], self.buttonPadding)
                    
                }
                
                #if DEBUG
                Button(action: {
                    self.appEnvironment.nuke()
                }) {
                    ZcashButton.nukeButton()
                    .frame(height: self.buttonHeight)
                    .padding([.leading, .trailing], self.buttonPadding)
                }
                #endif
                NavigationLink(
                    destination: RestoreWallet()
                    .environmentObject(appEnvironment)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarHidden(false)
                ) {
                    ZcashButton(color: Color.zYellow, fill: Color.clear, text: "Restore")
                    .frame(height: self.buttonHeight)
                    .padding([.leading, .trailing], self.buttonPadding)
                }
                
                
                Spacer()
            }
        }
    }
    
}

struct CreateNewWallet_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewWallet()
            .colorScheme(.dark)
    }
}
