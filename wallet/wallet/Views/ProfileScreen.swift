//
//  ProfileScreen.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI


struct ProfileScreen: View {
    @Binding var zAddress: String
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    var body: some View {
        NavigationView {
            ZStack {
                ZcashBackground()
                VStack(alignment: .center, spacing: 16) {
                    Image("zebra_profile")
                    Text("Shielded Zcash User\n" + (zAddress.shortZaddress ?? ""))
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    ZcashButton(color: .black, fill: Color.zAmberGradient1, text: "Send Feedback")
                        .frame(height: 68)
                        .padding(.horizontal, 48)
                    ZcashButton(color: .white, fill: .clear, text: "Backup Wallet")
                        .frame(height: 68)
                        .padding(.horizontal, 48)
                    Text("See Application Log")
                        .font(.system(size: 20))
                        .foregroundColor(Color.zLightGray)
                        .opacity(0.6)
                        .frame(height: 68)
                        .padding(.horizontal, 48)
                    
                    
                    ActionableMessage(message: "zECC SecureWallet v1.0", actionText: "Build 6", action: {}) // TODO: get real build number
                        .disabled(true)
                        .padding(.horizontal, 48)
                    Button(action: {
                        self.appEnvironment.nuke()
                    }) {
                        ZcashButton.nukeButton()
                            .frame(height: 48)
                            .padding([.leading, .trailing], 48)
                    }
                    Spacer()
                    
                    
                }
                
            }
        }
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen(zAddress: .constant("Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"))
    }
}
