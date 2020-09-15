//
//  NukeWarning.swift
//  wallet
//
//  Created by Francisco Gindre on 3/11/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct NukeWarning: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State private var showNukeAlert = false
    let buttonHeight: CGFloat = 50
    var disclaimer: String {
        """
        \("seed_remindertext".localized())
        
        \("Make sure you backed up your wallet before proceeding.".localized())
        
        \("If you nuke your wallet, there's no way to recover it.".localized())
        """
    }
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(spacing: 24) {
                HStack {
                    (Text("You are about to ")
                        .foregroundColor(.white)
                        + Text("NUKE ")
                            .foregroundColor(Color.zAmberGradient4)
                        + Text("your wallet!")
                            .foregroundColor(.white))
                        .font(.title)
                        .frame(alignment: .leading)
                    Spacer()
                }
                
                Text(disclaimer)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.zDarkGray3)
                Spacer()
                
                NavigationLink(destination: SeedBackup(proceedsToHome: false)
                                                .environmentObject(appEnvironment)
                                                .navigationBarHidden(false)
                                                .navigationBarTitle("", displayMode: .inline)) {
                    Text("Backup now!")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                        .frame(height: buttonHeight)
                }.isDetailLink(false)
                
                Button(action: {
                    self.showNukeAlert = true
                }) {
                    Text("NUKE WALLET")
                        .foregroundColor(.red)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 2)))
                        .frame(height: self.buttonHeight)
                }.alert(isPresented: $showNukeAlert) {
                    Alert(title: Text("Delete Wallet?"),
                          message: Text("You are about to")+Text(" nuke your wallet. ").foregroundColor(.red) + Text("Are you sure you want to proceed?"),
                          primaryButton: .default(
                            Text("I'm not sure")
                            ,action: { self.showNukeAlert = false}
                        ),
                          secondaryButton: .destructive(
                            Text("NUKE WALLET!"),
                            action: {
                                self.appEnvironment.nuke(abortApplication: true)
                          }
                        )
                    )
                }
                
            }.padding([.horizontal, .bottom], 24)
            
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(false)
        
    }
}

struct NukeWarning_Previews: PreviewProvider {
    static var previews: some View {
        NukeWarning()
    }
}
