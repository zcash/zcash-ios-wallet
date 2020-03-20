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
    @State var nukePressed = false
    static let buttonHeight = CGFloat(48)
    static let horizontalPadding = CGFloat(30)
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
                    
                    Text("Send Feedback")
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: Color.zYellow)))
                        .frame(height: Self.buttonHeight)
                       
                    
                    NavigationLink(destination: SeedBackup(hideNavBar: false).environmentObject(appEnvironment)
                        ) {
                        Text("Backup Wallet")
                            .foregroundColor(.white)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 1)))
                                               .frame(height: Self.buttonHeight)
                                               
                    }
                    Text("See Application Log")
                        .font(.system(size: 20))
                        .foregroundColor(Color.zLightGray)
                        .opacity(0.6)
                        .frame(height: Self.buttonHeight)
                      
                    
                    
                    ActionableMessage(message: "zECC SecureWallet v\(ZECCWalletEnvironment.appVersion ?? "Unknown")", actionText: "Build \(ZECCWalletEnvironment.appBuild ?? "Unknown")", action: {})
                        .disabled(true)
                      
                    
                    NavigationLink(destination: NukeWarning().environmentObject(appEnvironment), isActive: self.$nukePressed) {
                        EmptyView()
                    }.isDetailLink(false)
                    
                    Button(action: {
                        self.nukePressed = true
                    }) {
                         Text("NUKE WALLET")
                           .foregroundColor(.red)
                           .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
                            .frame(height: Self.buttonHeight)
                    }
                    
                    Spacer()

                }.padding(.horizontal, Self.horizontalPadding)
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
