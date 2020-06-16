//
//  ProfileScreen.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI


struct ProfileScreen: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var nukePressed = false
    static let buttonHeight = CGFloat(48)
    static let horizontalPadding = CGFloat(30)
    @State var isCopyAlertShown = false
    @Binding var isShown: Bool
    var body: some View {
        NavigationView {
            ZStack {
                ZcashBackground()
                VStack(alignment: .center, spacing: 16) {
                    Image("nighthawk_profile")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                    Button(action: {
                        self.isCopyAlertShown = true
                    }) {
                        Text("Shielded User\n" + (appEnvironment.initializer.getAddress()?.shortZaddress ?? ""))
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    }
                    
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
                      
                    
                    
                    ActionableMessage(message: "Nighthawk Wallet v\(ZECCWalletEnvironment.appVersion ?? "Unknown")", actionText: "Build \(ZECCWalletEnvironment.appBuild ?? "Unknown")", action: {})
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
                .alert(isPresented: self.$isCopyAlertShown) {
                    Alert(title: Text(""),
                          message: Text("Address Copied to clipboard!"),
                          dismissButton: .default(Text("OK"))
                    )
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing: ZcashCloseButton(action: {
                self.isShown = false
            }).frame(width: 30, height: 30))
        
        }
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen(isShown: .constant(true)).environmentObject(ZECCWalletEnvironment.shared)
    }
}
