//
//  ProfileScreen.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI


struct ProfileScreen: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var nukePressed = false
    static let buttonHeight = CGFloat(48)
    static let horizontalPadding = CGFloat(30)
    @State var copiedValue: PasteboardItemModel?
    @Binding var isShown: Bool
    @State var isFeedbackActive = false
    var body: some View {
        NavigationView {
            ZStack {
                ZcashBackground()
                VStack(alignment: .center, spacing: 16) {
                    Image("zebra_profile")
                    VStack {
                        Text("Shielded User".localized())
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                        Button(action: {
                            tracker.track(.tap(action: .copyAddress),
                                          properties: [:])
                            PasteboardAlertHelper.shared.copyToPasteBoard(value: self.appEnvironment.initializer.getAddress() ?? "", notify: "feedback_addresscopied".localized())

                        }) {
                            Text(appEnvironment.initializer.getAddress() ?? "")
                            .lineLimit(3)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        .onReceive(PasteboardAlertHelper.shared.publisher) { (item) in
                            self.copiedValue = item
                        }
                    }
                    .padding(0)
                    
                    Spacer()
                    #if ENABLE_LOGGING
                    NavigationLink(destination: LazyView(
                        FeedbackForm(isActive: self.$isFeedbackActive)
                        ),
                                   isActive: $isFeedbackActive) {
                                    
                                    Text("Send Feedback".localized())
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
                        Text("button_backup".localized())
                            .foregroundColor(.white)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 1)))
                            .frame(height: Self.buttonHeight)
                        
                    }
                    // TODO: Make Troubleshooting great again
//                    Text("See Application Log".localized())
//                        .font(.system(size: 20))
//                        .foregroundColor(Color.zLightGray)
//                        .opacity(0.6)
//                        .frame(height: Self.buttonHeight)
//
                    ActionableMessage(message: "\("ECC Wallet".localized()) v\(ZECCWalletEnvironment.appVersion ?? "Unknown")", actionText: "Build \(ZECCWalletEnvironment.appBuild ?? "Unknown")", action: {})
                        .disabled(true)
                    
                    
                    NavigationLink(destination: LazyView (
                        NukeWarning().environmentObject(self.appEnvironment)
                    ), isActive: self.$nukePressed) {
                        EmptyView()
                    }.isDetailLink(false)
                    
                    Button(action: {
                        tracker.track(.tap(action: .profileNuke), properties: [:])
                        self.nukePressed = true
                    }) {
                        Text("NUKE WALLET".localized())
                            .foregroundColor(.red)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
                            .frame(height: Self.buttonHeight)
                    }
                    
                    
                    
                }
                .padding(.horizontal, Self.horizontalPadding)
                .padding(.bottom, 30)
                .alert(item: self.$copiedValue) { (p) -> Alert in
                    PasteboardAlertHelper.alert(for: p)
                }
            }
            .onAppear {
                tracker.track(.screen(screen: .profile), properties: [:])
            }
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
