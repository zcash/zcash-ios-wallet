//
//  ProfileScreen.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit

struct ProfileScreen: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var nukePressed = false
    static let buttonHeight = CGFloat(48)
    static let horizontalPadding = CGFloat(30)
    @State var copiedValue: PasteboardItemModel?
    @Binding var isShown: Bool
    @State var alertItem: AlertItem?
    @State var showingSheet: Bool = false
    @State var shareItem: ShareItem? = nil
    @State var isFeedbackActive = false
    @State var isAwesomeMenuActive = false
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: LazyView(AwesomeMenu()
                                                        .environmentObject(AwesomeViewModel(isActive: $isAwesomeMenuActive))
                                                        ), isActive: $isAwesomeMenuActive) {
                    EmptyView()
                }
                ZcashBackground()
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        Image(UserSettings.shared.userEverShielded ? "profile_yellowzebra" : "profile_zebra")
                            .accentColor(.zYellow)
                            .accessibility(label: Text(UserSettings.shared.userEverShielded ? "A Golden zebra" : "A Zebra"))
                            .onLongPressGesture {
                                isAwesomeMenuActive = true
                            }
                            
                        VStack {
                            Text("profile_screen")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Button(action: {
                                tracker.track(.tap(action: .copyAddress),
                                              properties: [:])
                                PasteboardAlertHelper.shared.copyToPasteBoard(value: self.appEnvironment.getShieldedAddress() ?? "", notify: "feedback_addresscopied".localized())

                            }) {
                                Text(self.appEnvironment.getShieldedAddress() ?? "")
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
                            FeedbackForm(isActive: self.$isFeedbackActive)
                            ),
                                       isActive: $isFeedbackActive) {
                                        
                                        Text("button_feedback")
                                            .foregroundColor(.black)
                                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: Color.zYellow)))
                                            .frame(height: Self.buttonHeight)
                        }
                        #endif
                        
                        NavigationLink(destination: LazyView(
                            SeedBackup(hideNavBar: false)
                                .environmentObject(self.appEnvironment)
                            )
                        ) {
                            Text("button_backup")
                                .foregroundColor(.white)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 1)))
                                .frame(height: Self.buttonHeight)
                            
                        }
                        Button(action: {
                            self.showingSheet = true
                        }){
                            Text("Rescan Wallet".localized())
                                .foregroundColor(.zYellow)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .zYellow, lineWidth: 1)))
                                .frame(height: Self.buttonHeight)
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
                                .frame(height: Self.buttonHeight)
                        }

                        ActionableMessage(message: "\("ECC Wallet".localized()) v\(ZECCWalletEnvironment.appVersion ?? "Unknown")", actionText: "Build \(ZECCWalletEnvironment.appBuild ?? "Unknown")", action: {})
                            .disabled(true)
                        
                        Button(action: {
                            tracker.track(.tap(action: .profileNuke), properties: [:])
                            self.nukePressed = true
                        }) {
                            Text("NUKE WALLET".localized())
                                .foregroundColor(.red)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
                                .frame(height: Self.buttonHeight)
                        }
                        
                        NavigationLink(destination: LazyView (
                                               NukeWarning().environmentObject(self.appEnvironment)
                                           ), isActive: self.$nukePressed) {
                                               EmptyView()
                                           }.isDetailLink(false)
                        
                    }
                    .padding(.horizontal, Self.horizontalPadding)
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
                            }),
                            .default(Text("Quick Re-Scan"), action: {
                                self.appEnvironment.synchronizer.quickRescan()
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
                self.isShown = false
            }).frame(width: 30, height: 30))
        }
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen(isShown: .constant(true)).environmentObject(ZECCWalletEnvironment.shared)
    }
}
