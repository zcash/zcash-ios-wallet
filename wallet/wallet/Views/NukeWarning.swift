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
        \("nuke_nukewarning".localized())
        
        \("nuke_nukewarning2".localized())
        
        \("nuke_nukewarning3".localized())
        """
    }
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(spacing: 24) {
                HStack {
                    Text("nuke_title")
                        .foregroundColor(.white)
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
                    Text("nuke_backupbutton")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                        .frame(height: buttonHeight)
                }.isDetailLink(false)
                
                Button(action: {
                    self.showNukeAlert = true
                }) {
                    Text("nuke_nukeButton")
                        .foregroundColor(.red)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 2)))
                        .frame(height: self.buttonHeight)
                }.alert(isPresented: $showNukeAlert) {
                    Alert(title: Text("nuke_alerttitle"),
                          message: Text("nuke_alertmessage"),
                          primaryButton: .default(
                            Text("nuke_alertcancel")
                            ,action: { self.showNukeAlert = false}
                        ),
                          secondaryButton: .destructive(
                            Text("nuke_alertconfirm"),
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
