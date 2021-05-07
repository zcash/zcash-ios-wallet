//
//  ProfileScreen.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit

fileprivate struct ScreenConstants {
    static let buttonHeight = CGFloat(48)
    static let horizontalPadding = CGFloat(30)
}

struct ProfileScreen: View {
    enum Destination: Int, Identifiable, Hashable {
        case feedback
        case seedBackup
        case nuke
        var id: Int {
            return self.rawValue
        }
    }
    
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var nukePressed = false
    @State var copiedValue: PasteboardItemModel?
    @State var alertItem: AlertItem?
    @State var showingSheet: Bool = false
    @State var shareItem: ShareItem? = nil
    @State var destination: Destination?
    
    var body: some View {
        NavigationView {
            ZStack {
              
                ZcashBackground()
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        Image(UserSettings.shared.userEverShielded ? "profile_yellowzebra" : "profile_zebra")
                            .accentColor(.zYellow)
                            .accessibility(label: Text(UserSettings.shared.userEverShielded ? "A Golden zebra" : "A Zebra"))
                            
                        VStack {
                            Text("profile_screen")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Button(action: {
                                tracker.track(.tap(action: .copyAddress),
                                              properties: [:])
                                PasteboardAlertHelper.shared.copyToPasteBoard(value: self.appEnvironment.synchronizer.unifiedAddress.zAddress, notify: "feedback_addresscopied".localized())

                            }) {
                                Text(self.appEnvironment.synchronizer.unifiedAddress.zAddress)
                                .lineLimit(3)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                            }
                            .onReceive(PasteboardAlertHelper.shared.publisher) { (item) in
                                self.copiedValue = item
                            }
                        }
                        .padding(0)
                        
                        #if ENABLE_LOGGING
                        NavigationLink(destination: LazyView(
                            FeedbackForm(isActive: $destination)
                        ), tag: Destination.feedback, selection: $destination) {
                                        
                                        Text("button_feedback")
                                            .foregroundColor(.black)
                                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: Color.zYellow)))
                                            .frame(height: ScreenConstants.buttonHeight)
                        }
                        #endif
                        
                        NavigationLink(destination: LazyView(
                            SeedBackup(hideNavBar: false)
                                .environmentObject(self.appEnvironment)
                        ), tag: Destination.seedBackup, selection: $destination
                        ) {
                            Text("button_backup")
                                .foregroundColor(.white)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 1)))
                                .frame(height: ScreenConstants.buttonHeight)
                            
                        }
                        Button(action: {
                            self.showingSheet = true
                        }){
                            Text("Rescan Wallet".localized())
                                .foregroundColor(.zYellow)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .zYellow, lineWidth: 1)))
                                .frame(height: ScreenConstants.buttonHeight)
                        }
                        
                        Button(action: {
                            do {
                                guard let latestLogfile = try LogfileHelper.latestLogfile() else {
                                    self.alertItem = AlertItem(type: .feedback(message: "No logfile found"))
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
                                .foregroundColor(Color.zLightGray)
                                .opacity(0.6)
                                .frame(height: ScreenConstants.buttonHeight)
                        }

                        ActionableMessage(message: "\(appName) v\(ZECCWalletEnvironment.appVersion ?? "Unknown")", actionText: "Build \(ZECCWalletEnvironment.appBuild ?? "Unknown")", action: {})
                            .disabled(true)
                        
                        Button(action: {
                            tracker.track(.tap(action: .profileNuke), properties: [:])
                            self.nukePressed = true
                        }) {
                            Text("NUKE WALLET".localized())
                                .foregroundColor(.red)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
                                .frame(height: ScreenConstants.buttonHeight)
                        }
                        
                        NavigationLink(destination: LazyView (
                                               NukeWarning().environmentObject(self.appEnvironment)
                                           ), isActive: self.$nukePressed) {
                                               EmptyView()
                                           }.isDetailLink(false)
                        
                    }
                    .padding(.horizontal, ScreenConstants.horizontalPadding)
                    .padding(.bottom, 15)
                    .alert(item: self.$copiedValue) { (p) -> Alert in
                        PasteboardAlertHelper.alert(for: p)
                    }

                }
            }
            .onAppear {
                tracker.track(.screen(screen: .profile), properties: [:])
            }
            .actionSheet(isPresented: $showingSheet) {
                       ActionSheet(
                           title: Text("Do you want to re-scan your wallet?"),
                           message: Text("roll back your local data and sync it again"),
                        buttons: [
                            .destructive(Text("Full Re-scan"), action: {
                                self.appEnvironment.synchronizer.fullRescan()
                                self.presentationMode.wrappedValue.dismiss()
                            }),
                            .default(Text("Quick Re-Scan"), action: {
                                self.appEnvironment.synchronizer.quickRescan()
                                self.presentationMode.wrappedValue.dismiss()
                            }),
                            .default(Text("Dismiss".localized()))
                        ]
                       )
                   }
            .sheet(item: self.$shareItem, content: { item in
                ShareSheet(activityItems: [item.activityItem])
            })
            .alert(item: self.$alertItem, content: { a in
                a.asAlert()
            })
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing: ZcashCloseButton(action: {
                tracker.track(.tap(action: .profileClose), properties: [:])
                self.presentationMode.wrappedValue.dismiss()
            }).frame(width: 30, height: 30))
        }
    }
    
    var appName: String {
        if ZcashSDK.isMainnet {
            return "ECC Wallet".localized()
        } else {
            return "ECC Testnet"
        }
    }
}

//struct ProfileScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileScreen(isShown: .constant(nill)).environmentObject(ZECCWalletEnvironment.shared)
//    }
//}
