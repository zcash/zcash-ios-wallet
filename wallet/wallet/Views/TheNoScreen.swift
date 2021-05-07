//
//  TheNoScreen.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 5/7/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI



struct TheNoScreen: View {
    @State var alert: AlertType? = nil
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
   
    @ViewBuilder func theUnscreen() -> some View {
        ZStack {
            ZcashBackground.amberSplashScreen
            ZcashLogo(fillStyle: Color.black)
                .scaleEffect(0.66)
                
        }
        .navigationBarHidden(true)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                do {
                    try appEnvironment.initialize()
                    appEnvironment.state = .initalized
                } catch {
                    self.alert = .error(underlyingError: error)
                }
            }
        }
    }
    
    @ViewBuilder func viewForState(_ state: WalletState) -> some View {
        switch state {
        case .unprepared:
            theUnscreen()
        case .initalized,
             .syncing,
             .synced:

            Home()
                .environmentObject(HomeViewModel())
                
        case .uninitialized:
            CreateNewWallet().environmentObject(appEnvironment)

        }
    }
    var body: some View {
        viewForState(appEnvironment.state)
    }
}

struct TheNoScreen_Previews: PreviewProvider {
    static var previews: some View {
        TheNoScreen()
    }
}
