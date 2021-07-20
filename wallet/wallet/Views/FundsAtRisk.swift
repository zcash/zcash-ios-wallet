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
        \("seed_remindertext".localized())
        
        \("seed_remindertext2".localized())
        """
    }
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(spacing: 24) {
                HStack {
                    Text("seed_reminder")
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
                
                NavigationLink(destination: SeedBackup(proceedsToHome: true).environmentObject(appEnvironment)) {
                    Text("button_backup")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                        .frame(height: buttonHeight)
                }.isDetailLink(false)
                
                NavigationLink(destination: LazyView(
                    Home(viewModel: ModelFlyWeight.shared.modelBy(defaultValue: HomeViewModel()))
                    )) {
                    Text("button_skip".localized())
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
