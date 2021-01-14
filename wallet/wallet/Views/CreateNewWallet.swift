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
    
    enum AlertType: Identifiable {
        case feedback(destination: Destinations, cause: Error)
        case error(cause:Error)
        var id: Int {
            switch self {
            case .error:
                return 0
            case .feedback:
                return 1
            }
        }
    }
    
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var error: UserFacingErrors?
    @State var showError: AlertType?
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
                        tracker.track(.tap(action: .landingBackupWallet), properties: [:])
                        try self.appEnvironment.createNewWallet()
                        self.destination = Destinations.createNew
                    } catch WalletError.createFailed(let e) {
                        if case SeedManager.SeedManagerError.alreadyImported = e {
                            self.showError = AlertType.feedback(destination: .createNew, cause: e)
                        } else {
                            fail(WalletError.createFailed(underlying: e))
                        }
                    } catch {
                        fail(error)
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
                    Button(action: {
                        guard !ZECCWalletEnvironment.shared.credentialsAlreadyPresent() else {
                            self.showError = .feedback(destination: .restoreWallet, cause: SeedManager.SeedManagerError.alreadyImported)
                            return
                        }
                        self.destination = .restoreWallet
                    }) {
                        Text("Restore".localized())
                            .foregroundColor(Color.zDarkGray3)
                            .font(.system(size: 20))
                            .frame(height: self.buttonHeight)
                    }
                }
            }
            .padding([.horizontal, .bottom], self.buttonPadding)
        }
        .onAppear {
            tracker.track(.screen(screen: .landing), properties: [ : ])
        }
        .alert(item: self.$showError) { (alertType) -> Alert in
            switch alertType {
            case .error(let cause):
                let userFacingError = mapToUserFacingError(ZECCWalletEnvironment.mapError(error: cause))
                return Alert(title: Text(userFacingError.title),
                             message: Text(userFacingError.message),
                dismissButton: .default(Text("button_close")))
            case .feedback(let destination, let cause):
                if let feedbackCause = cause as? SeedManager.SeedManagerError,
                   case SeedManager.SeedManagerError.alreadyImported = feedbackCause {
                    return existingCredentialsFound(originalDestination: destination)
                } else {
                    return defaultAlert(cause)
                }

            }
        }
    }
    
    func fail(_ error: Error) {
        let message = "could not create new wallet:"
        logger.error("\(message) \(error)")
        tracker.track(.error(severity: .critical),
                      properties: [
                        ErrorSeverity.messageKey : message,
                        ErrorSeverity.underlyingError : "\(error)"
                        ])
       
       self.showError = .error(cause: mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error)))
        
    }
    
    func existingCredentialsFound(originalDestination: Destinations) -> Alert {
        Alert(title: Text("Existing keys found!"),
              message: Text("it appears that this device already has keys stored on it. What do you want to do?"),
              primaryButton: .default(Text("Restore existing keys"),
                                      action: {
                                        do {
                                            try ZECCWalletEnvironment.shared.initialize()
                                            self.destination = .createNew
                                        } catch {
                                            DispatchQueue.main.async {
                                                self.fail(error)
                                            }
                                        }
                                      }),
              secondaryButton: .destructive(Text("Discard them and continue"),
                                            action: {
                                                
                                                ZECCWalletEnvironment.shared.nuke(abortApplication: false)
                                                do {
                                                    try ZECCWalletEnvironment.shared.reset()
                                                } catch {
                                                    self.fail(error)
                                                    return
                                                }
                                                switch originalDestination {
                                                case .createNew:
                                                    do {
                                                        try self.appEnvironment.createNewWallet()
                                                        self.destination = originalDestination
                                                    } catch {
                                                            self.fail(error)
                                                    }
                                                case .restoreWallet:
                                                    self.destination = originalDestination
                                                
                                                }
                                            }))
    }
    
    
    func defaultAlert(_ error: Error? = nil) -> Alert {
        guard let e = error else {
            return Alert(title: Text("Error Initializing Wallet"),
                 message: Text("There was a problem initializing the wallet"),
                 dismissButton: .default(Text("button_close")))
        }
        
        return Alert(title: Text("Error"),
                     message: Text(mapToUserFacingError(ZECCWalletEnvironment.mapError(error: e)).message),
                     dismissButton: .default(Text("button_close")))
        
    }
}

struct CreateNewWallet_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewWallet()
            .colorScheme(.dark)
    }
}

extension CreateNewWallet.Destinations: Hashable {}
