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
    
   
    var body: some View {
        
        NavigationView {
            ZStack {
                
                Color.black
                
                VStack(alignment: .center, spacing: 24) {
                    Spacer()
                    ZcashLogo()
                    Spacer()
                    Text("12% Synced")
                    Spacer()
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                        ZcashButton(color: Color.black, fill: Color.zYellow, text: "Create New Wallet")
                            .frame(height: 58)
                    }.padding([.leading, .trailing], 40)
                    
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                        ZcashButton(color: Color.zYellow, fill: Color.clear, text: "Restore")
                            .frame(height: 58)
                    }.padding([.leading, .trailing], 40)
                    Spacer()
                }
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
