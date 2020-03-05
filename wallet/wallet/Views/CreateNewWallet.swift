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
    let buttonPadding: CGFloat = 24
    let buttonHeight: CGFloat = 50
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
                    Text("Create New")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                        
                        .frame(height: self.buttonHeight)
  
                }
                
                #if DEBUG
                Button(action: {
                    self.appEnvironment.nuke()
                }) {
                    Text("NUKE WALLET")
                        .foregroundColor(.red)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
                        .frame(height: self.buttonHeight)
                    
                }
                #endif
                NavigationLink(
                    destination: RestoreWallet()
                        .environmentObject(appEnvironment)
                        .navigationBarTitle("Restore from Seed Phrase", displayMode: .inline)
                        .navigationBarHidden(false)
                        .navigationBarBackButtonHidden(false)
                ) {
                    Text("Restore")
                        .foregroundColor(Color.zDarkGray3)
                        .font(.system(size: 20))
                        .frame(height: self.buttonHeight)
                    
                }
                
            } .padding([.horizontal, .bottom], self.buttonPadding)
        }
    }
    
}

struct CreateNewWallet_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewWallet()
            .colorScheme(.dark)
    }
}
