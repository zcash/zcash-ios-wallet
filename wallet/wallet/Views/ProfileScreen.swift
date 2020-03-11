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
    static let buttonHeight = CGFloat(48)
    static let horizontalPadding = CGFloat(48)
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
                        .frame(height: Self.buttonHeight)
                        .padding(.horizontal, Self.horizontalPadding)
                    NavigationLink(destination: SeedBackup().environmentObject(appEnvironment)
                        .navigationBarHidden(false)) {
                        ZcashButton(color: .white, fill: .clear, text: "Backup Wallet")
                                               .frame(height: Self.buttonHeight)
                                               .padding(.horizontal, Self.horizontalPadding)
                    }
                    Text("See Application Log")
                        .font(.system(size: 20))
                        .foregroundColor(Color.zLightGray)
                        .opacity(0.6)
                        .frame(height: Self.buttonHeight)
                        .padding(.horizontal, Self.horizontalPadding)
                    
                    
                    ActionableMessage(message: "zECC SecureWallet v\(ZECCWalletEnvironment.appVersion ?? "Unknown")", actionText: "Build \(ZECCWalletEnvironment.appBuild ?? "Unknown")", action: {})
                        .disabled(true)
                        .padding(.horizontal, Self.horizontalPadding)
                    Button(action: {
                        self.appEnvironment.nuke()
                    }) {
                        ZcashButton.nukeButton()
                            .frame(height: Self.buttonHeight)
                            .padding([.leading, .trailing], Self.horizontalPadding)
                    }
                    Spacer()

                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(false)
        }
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen(zAddress: .constant("Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"))
    }
}
