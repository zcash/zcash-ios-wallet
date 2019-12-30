//
//  CreateNewWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct CreateNewWallet: View {
    
    init() {
        UINavigationBar.appearance().backgroundColor = .black
    }
    
    let itemSpacing: CGFloat = 24
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 58
    var body: some View {
        
        NavigationView {
            ZStack {
                
                Color.black
                
                VStack(alignment: .center, spacing: itemSpacing) {
                    Spacer()
                    ZcashLogo()
                    Spacer()
                    Text("12% Synced")
                    Spacer()
                    NavigationLink(destination: BackupWallet().navigationBarHidden(true)) {
                        ZcashButton(color: Color.black, fill: Color.zYellow, text: "Create New Wallet")
                                .frame(height: buttonHeight)
                         .padding([.leading, .trailing], buttonPadding)
                        
                    }
                        
                    ZcashButton(color: Color.zYellow, fill: Color.clear, text: "Restore")
                        .frame(height: buttonHeight)
                    .padding([.leading, .trailing], buttonPadding)
                   
                    Spacer()
                }
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
    }
}

struct CreateNewWallet_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewWallet()
            .colorScheme(.dark)
    }
}
