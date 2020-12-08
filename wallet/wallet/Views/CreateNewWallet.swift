//
//  CreateNewWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct CreateNewWallet: View {
    
    enum Destinations: Int {
        case createNew
        case restoreWallet
    }
    
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var error: UserFacingErrors?
    @State var showError = false
    @State var destination: Destinations?
    let itemSpacing: CGFloat = 24
    let buttonPadding: CGFloat = 24
    let buttonHeight: CGFloat = 50
    var body: some View {

        ZStack {
            NavigationLink(destination:
                LazyView (
                    BackupWallet().environmentObject(self.appEnvironment)
                    .navigationBarHidden(true)
                ),
                           tag: Destinations.createNew,
                           selection: $destination
                
            ) {
              EmptyView()
            }
            ZcashBackground()
            
            VStack(alignment: .center, spacing: self.itemSpacing) {
                Spacer()
                
                ZcashLogo()
                
                Spacer()
                Button(action: {
                    do {
                         /// TODO: change previous navigation link to button to capture action
                         tracker.track(.tap(action: .landingBackupWallet), properties: [:])
                         try self.appEnvironment.createNewWallet()
                        self.destination = Destinations.createNew
                     } catch {
                         let message = "could not create new wallet:"
                         logger.error("\(message) \(error)")
                         tracker.track(.error(severity: .critical),
                                       properties: [
                                         ErrorSeverity.messageKey : message,
                                         ErrorSeverity.underlyingError : "\(error)"
                                         ])
                        self.error = mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error))
                        self.showError = true
                     }

                }) {
                    Text("Create New".localized())
                                          .font(.system(size: 20))
                                          .foregroundColor(Color.black)
                                          .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                                          
                                          .frame(height: self.buttonHeight)
                }
                
                
                #if DEBUG
                Button(action: {
                    self.appEnvironment.nuke()
                }) {
                    Text("NUKE WALLET".localized())
                        .foregroundColor(.red)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
                        .frame(height: self.buttonHeight)
                    
                }
                #endif
                NavigationLink(
                    destination: RestoreWallet()
                                    .environmentObject(self.appEnvironment),
                               tag: Destinations.restoreWallet,
                               selection: $destination
                        
                ) {
                    Text("Restore".localized())
                        .foregroundColor(Color.zDarkGray3)
                        .font(.system(size: 20))
                        .frame(height: self.buttonHeight)
                    
                }
                
            }
            .padding([.horizontal, .bottom], self.buttonPadding)
        }
        .onAppear {
            tracker.track(.screen(screen: .landing), properties: [ : ])
        }
        .alert(isPresented: $showError) {
            guard let e = error else {
                return Alert(title: Text("Error Initializing Wallet"),
                             message: Text("There was a problem initializing the wallet"),
                             dismissButton: .default(Text("button_close")))
            }
            let userFacingError = mapToUserFacingError(ZECCWalletEnvironment.mapError(error: e))
            return Alert(title: Text(userFacingError.title),
                         message: Text(userFacingError.title),
            dismissButton: .default(Text("button_close")))
        }
    }
    
}

struct CreateNewWallet_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewWallet()
            .colorScheme(.dark)
    }
}

extension CreateNewWallet.Destinations: Hashable {
    
}
