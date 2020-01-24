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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        appearance.titleTextAttributes = [
            .font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        
    }
    
    let itemSpacing: CGFloat = 24
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 58
    var body: some View {
        
        
        ZStack {
            
            ZcashBackground()
            
            VStack(alignment: .center, spacing: self.itemSpacing) {
                Spacer()
                
                ZcashLogo()
                    .scaleEffect(0.5)
                
                Spacer()
                Text("12% Synced")
                    .foregroundColor(.white)
                Spacer()
                NavigationLink(destination:
                    BackupWallet()
                        .navigationBarHidden(true)
                    
                ) {
                    ZcashButton(color: Color.black, fill: Color.zYellow, text: "Create New Wallet")
                        .frame(height: self.buttonHeight)
                        .padding([.leading, .trailing], self.buttonPadding)
                    
                }
                
                ZcashButton(color: Color.zYellow, fill: Color.clear, text: "Restore")
                    .frame(height: self.buttonHeight)
                    .padding([.leading, .trailing], self.buttonPadding)
                
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


/**
 .background(NavigationConfigurator { nc in
 nc.navigationBar.barTintColor = UIColor.zDarkGray
 nc.navigationBar.isTranslucent = true
 nc.navigationBar.isHidden = true
 nc.navigationBar.tintColor = UIColor.zLightGray
 nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white,
 .font : UIFont.systemFont(ofSize: 20, weight: .light)
 ]
 })
 */
