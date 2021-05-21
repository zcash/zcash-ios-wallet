//
//  OhMyScreen.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 5/10/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

final class OhMyScreenViewModel: ObservableObject {
   
    var error: Error
    init(failure: Error) {
        self.error = failure
    }
}

fileprivate struct ScreenConstants {
    static let buttonHeight = CGFloat(48)
    static let horizontalPadding = CGFloat(30)
}

struct OhMyScreen: View {
    enum Destination: Int, Identifiable, Hashable {
        case feedback
        case seedBackup
        case nuke
        var id: Int {
            return self.rawValue
        }
    }
    @State var shareItem: ShareItem? = nil
    @State var destination: Destination?
    @State var alertItem: AlertItem?
    @State var nukePressed: Bool = false
    @EnvironmentObject var environment: OhMyScreenViewModel
    @Environment(\.walletEnvironment) var appEnvironment
    
    var body: some View {
        ZStack {
            ZcashBackground.amberSplashScreen
            ScrollView {
                VStack(spacing: 24) {

                    Text("We couldn't initialize your wallet")
                        .foregroundColor(.black)
                        .font(.system(size: 24))
                    if let error = environment.error {
                        Text("""
                             Reason:
                             \(error.localizedDescription)
                             """)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Close the app and try to restart it.")
                        Text("If you have done so, here are some options:")
                    }
                    .padding(0)
                    NavigationLink(destination: SeedBackup(hideNavBar: false,
                                                           error: nil,
                                                           showError: false,
                                                           copyItemModel: nil,
                                                           proceedsToHome: false).environmentObject(ZECCWalletEnvironment.shared),
                                   tag: Destination.seedBackup,
                                   selection: self.$destination,
                                   label: {
                                    Text("Backup Seed")
                                        .foregroundColor(.black)
                                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .black, lineWidth: 1)))
                                            .frame(height: 48)
                                   })
                    
                    #if ENABLE_LOGGING
                    NavigationLink(destination: LazyView(
                        FeedbackForm(isActive: $destination)
                    ), tag: Destination.feedback, selection: $destination) {
                                    
                                    Text("button_feedback")
                                        .foregroundColor(.black)
                                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .black, lineWidth: 1)))
                                        .frame(height: 48)
                    }
                    #endif
                    
                    Button(action: {
                        do {
                            guard let latestLogfile = try LogfileHelper.latestLogfile() else {
                                self.alertItem = AlertItem(type: .feedback(message: "No logfile found", action: nil))
                                return
                            }
                            self.shareItem = ShareItem.file(fileUrl: latestLogfile)
                            
                        } catch {
                            logger.error("failed to get logfile \(error)")
                            self.alertItem = AlertItem(type: .error(underlyingError: error))
                        }
                    }) {
                        Text("button_applicationlogs".localized())
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .opacity(0.6)
                            .frame(height: ScreenConstants.buttonHeight)
                    }
                    
                    Button(action: {
                        do {
                            try appEnvironment.wipe(abortApplication: false)
                            self.alertItem = AlertItem(type: .feedback(
                                                        message: "SUCCESS! Wallet data cleared. Please relaunch to rescan!",
                                                        action: {
                                abort()
                            }))
                        } catch {
                            self.alertItem = AlertItem(
                                type: AlertType.actionable(
                                                        title: "Wipe Failed",
                                                        message: "Wipe operation failed with error \(error). You might want to screenshot this. Your app could work properly. You can close it and restart it, or nuke it.",
                                                        destructiveText: "NUKE WALLET".localized(),
                                    destructiveAction: { appEnvironment.nuke() },
                                                        dismissText: "Close App",
                                                        dismissAction: {
                                                            abort()
                                                        })
                            )
                        }
                    }, label: {
                        Text("Wipe")
                            .foregroundColor(.black)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .black, lineWidth: 1)))
                                .frame(height: 48)
                    })
                    
                    ActionableMessage(message: "\(ZECCWalletEnvironment.appName) v\(ZECCWalletEnvironment.appVersion ?? "Unknown")", actionText: "Build \(ZECCWalletEnvironment.appBuild ?? "Unknown")", action: {})
                        .disabled(true)
                    
                    Button(action: {
                        nukeWallet()
                    }) {
                        Text("NUKE WALLET".localized())
                            .foregroundColor(.red)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
                            .frame(height: ScreenConstants.buttonHeight)
                    }
                    
                    NavigationLink(destination: LazyView (
                        NukeWarning().environmentObject(ZECCWalletEnvironment.shared)
                                       ), isActive: self.$nukePressed) {
                                           EmptyView()
                                       }.isDetailLink(false)
                    
                    
                }
                .padding(.horizontal)
            }
        }
        .sheet(item: self.$shareItem, content: { item in
            ShareSheet(activityItems: [item.activityItem])
        })
        .alert(item: self.$alertItem, content: { a in
            a.asAlert()
        })
    }
    
    func nukeWallet() {
        tracker.track(.tap(action: .profileNuke), properties: [:])
        self.nukePressed = true
    }
}

struct OhMyScreen_Previews: PreviewProvider {
    static var previews: some View {
        OhMyScreen()
    }
}
