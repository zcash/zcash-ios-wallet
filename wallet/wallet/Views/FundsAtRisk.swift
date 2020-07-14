//
//  FundsAtRisk.swift
//  wallet
//
//  Created by Francisco Gindre on 3/4/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct FundsAtRisk: View {
    
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    let buttonHeight: CGFloat = 50
    var disclaimer: String {
        """
        \("Remember, with Zcash YOU are the bank. Only you, or anyone with your seed phrase, has access to your wallet.".localized())
        
        \("You should back this up immediately".localized())
        \("as no one else can restore it for you".localized())
        \("if your device is lost/broken/stolen…".localized())
        """
    }
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(spacing: 24) {
                HStack {
                    (Text("Your ".localized())
                        .foregroundColor(.white)
                        + Text("funds ".localized())
                            .foregroundColor(Color.zAmberGradient4)
                        + Text("are at risk!".localized())
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
                
                NavigationLink(destination: SeedBackup(proceedsToHome: true).environmentObject(appEnvironment)) {
                    Text("Backup now!".localized())
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                        .frame(height: buttonHeight)
                }.isDetailLink(false)
                
                NavigationLink(destination:  Home(amount: 0, verifiedBalance: appEnvironment.initializer.getBalance().asHumanReadableZecBalance()).environmentObject(appEnvironment)) {
                    Text("Not now".localized())
                        .foregroundColor(Color.zDarkGray3)
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .frame(height: buttonHeight)
                }.isDetailLink(false)
                
            }.padding([.horizontal, .bottom], 24)
            
        }
        .onAppear {
            /// TODO: change Navigation links to buttons
            tracker.track(.tap(action: .landingBackupSkipped1), properties: [:])
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        
    }
}

struct FundsAtRisk_Previews: PreviewProvider {
    static var previews: some View {
        FundsAtRisk()
    }
}
