//
//  TheNoScreen.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 5/7/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit

struct TheNoScreen: View {
    @StateObject var appEnvironment: ZECCWalletEnvironment
   
    @ViewBuilder func theUnscreen() -> some View {
        ZStack(alignment: .center) {
            ZcashBackground.amberSplashScreen
            ZcashLogo(fillStyle: Color.black)
                .frame(width: 167,
                       height: 167,
                       alignment: .center)
        }
        .navigationBarHidden(true)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                do {
                    let initialState = ZECCWalletEnvironment.getInitialState()
                    switch initialState {
                    case .unprepared, .initalized:
                        try appEnvironment.initialize()
                        appEnvironment.state = .initalized

                    default:
                        appEnvironment.state = initialState
                    }

                } catch {
                    self.appEnvironment.state = .failure(error: error)
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

            Home(viewModel: ModelFlyWeight.shared.modelBy(defaultValue: HomeViewModel()))
                .environmentObject(appEnvironment)
                
        case .uninitialized:
            CreateNewWallet().environmentObject(appEnvironment)
        
        case .failure(let error):
            OhMyScreen().environmentObject(
                OhMyScreenViewModel(failure: mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error)))
            )
        }
    }
    var body: some View {
        viewForState(appEnvironment.state)
            .transition(.opacity)
    }
}

//struct TheNoScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        TheNoScreen()
//    }
//}
