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
    
    var radialGradient: some View {
        let colors = Gradient(colors: [Color.zGray, .black])
        let conic = RadialGradient(gradient: colors, center: .center, startRadius: 50, endRadius: 200)
        return Circle()
            .fill(conic)
            .frame(width: 400, height: 400)
    }
    
    let itemSpacing: CGFloat = 24
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 58
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {

                Background()
                
                VStack(alignment: .center, spacing: self.itemSpacing) {
                    Spacer()
                    
                    ZcashLogo()
                        .scaleEffect(0.5)
                    
                    Spacer()
                    Text("12% Synced")
                    Spacer()
                    NavigationLink(destination: BackupWallet().navigationBarHidden(true)) {
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
