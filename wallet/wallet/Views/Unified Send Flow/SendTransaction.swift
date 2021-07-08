//
//  SendTransaction.swift
//  wallet
//
//  Created by Francisco Gindre on 7/27/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit
struct SendTransaction: View {
    @EnvironmentObject var flow: SendFlowEnvironment
    @State var showError = false
    @State var authError: AuthenticationEvent = .userDeclined
    @State var sendOk = false
    @State var addressHelperSelection: AddressHelperView.Selection = .none 
    @State var scanViewModel = ScanAddressViewModel(shouldShowSwitchButton: false, showCloseButton: true)
    var availableBalance: Bool {
        ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value > 0
    }
    
    var addressSubtitle: String {
        let environment = ZECCWalletEnvironment.shared
        guard !flow.address.isEmpty else {
            return "feedback_default".localized()
        }
        let validShielded = environment.isValidShieldedAddress(flow.address)
        let validTransparent = environment.isValidTransparentAddress(flow.address)
        
        if validShielded {
            return subtextForValid(shielded: flow.address)
        }
        
        if validTransparent {
            return subtextForValid(transparent: flow.address)
        }
        
        return "feedback_invalidaddress".localized()
    }
    
    func subtextForValid(shielded address: String) -> String {
        if ZECCWalletEnvironment.shared.synchronizer.unifiedAddress.zAddress == address {
            return "feedback_sameaddress".localized()
        } else {
            return "feedback_shieldedaddress".localized()
        }
    }
    
    func subtextForValid(transparent address: String) -> String {
        if ZECCWalletEnvironment.shared.synchronizer.unifiedAddress.tAddress == address {
            return "This is your Auto Shielding address".localized()
        } else {
            return "feedback_transparentaddress".localized()
        }
    }
    
    func amountSubtitle(amount: String) -> String {
        if availableBalance,
            let balance = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value)),
            let amountToSend = NumberFormatter.zecAmountFormatter.number(from: flow.amount)?.doubleValue {
            if ZECCWalletEnvironment.shared.sufficientFundsToSend(amount: amountToSend) {
                return String(format:NSLocalizedString("You Have %@ sendable ZEC", comment: ""), "\(balance)")
            } else {
                return String(format: "%@ sendable ZEC. You don't have sufficient funds to cover the amount + Miner Fee of %@ ZEC", "\(balance)", "\(ZECCWalletEnvironment.minerFee)")
            }
        } else {
            return "You don't have any sendable ZEC yet"
        }
    }
    
    var validAddress: Bool {
        ZECCWalletEnvironment.shared.isValidAddress(flow.address)
    }
    
    var sufficientAmount: Bool {
        let amount = (flow.doubleAmount ??  0 )
        return amount > 0 && amount <= ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value
    }
    
    var validForm: Bool {
        availableBalance && validAddress && sufficientAmount && validMemo
    }
    
    var validMemo: Bool {
        flow.memo.count >= 0 && flow.memo.count <= charLimit
    }
    
    var addressInBuffer: AnyView {
        
        if let clipboard = UIPasteboard.general.string,
            ZECCWalletEnvironment.shared.isValidAddress(clipboard),
            clipboard.shortZaddress != nil {
                
            if let lastUsed = UserSettings.shared.lastUsedAddress {
                return AddressHelperView(selection: $addressHelperSelection, mode: .both(clipboard: clipboard, lastUsed: lastUsed)).eraseToAnyView()
            } else {
                return AddressHelperView(selection: $addressHelperSelection, mode: .clipboard(address: clipboard)).eraseToAnyView()
            }
        } else if let lastUsed = UserSettings.shared.lastUsedAddress {
            return AddressHelperView(selection: $addressHelperSelection, mode: .lastUsed(address: lastUsed)).eraseToAnyView()
        } else {
            return AnyView(EmptyView())
        }
        
        
    }
    var charLimit: Int {
        if flow.includeSendingAddress {
            return ZECCWalletEnvironment.memoLengthLimit - SendFlowEnvironment.replyToAddress((ZECCWalletEnvironment.shared.getShieldedAddress() ?? "")).count
        }
        return ZECCWalletEnvironment.memoLengthLimit
    }
    var recipientActiveColor: Color {
        let address = flow.address
        if ZECCWalletEnvironment.shared.isValidShieldedAddress(address) {
            return Color.zYellow
        } else if ZECCWalletEnvironment.shared.isValidTransparentAddress(address) {
            return Color.zTransparentBlue
        } else {
            return Color.zGray2
        }
    }
    
    var body: some View {
        ZStack {
            ZcashBackground()
            
            VStack(alignment: .leading, spacing: 20) {
                
                ZcashNavigationBar(
                    leadingItem: {
                        Button(action: {
                            self.flow.close()
                        }) {
                            Image("Back")
                                .renderingMode(.original)
                            .accessibility(label: Text("button_back"))
                        }
                },
                    headerItem: {
                        ZecAmountHeader(amount: self.flow.amount)
                },
                    
                    trailingItem: {
                        Button(action: {
                            AuthenticationHelper.authenticate(with: "send_securityauth".localized())
                        }) {
                            Text("button_send")
                                .foregroundColor(.black)
                                .zcashButtonBackground(shape: .rounded(fillStyle: .solid(color: .zAmberGradient2)))
                                .frame(width: 63, height: 24)
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                            
                        }
                            .opacity(validForm ? 1.0 : 0.3 ) // validate this
                            .disabled(!validForm)
                }
                )
                    .frame(height: 64)
                    .edgesIgnoringSafeArea([.horizontal])
                
                ZcashActionableTextField(
                    title: "\("label_to".localized()):",
                    subtitleView: AnyView(
                        Text.subtitle(text: addressSubtitle)
                    ),
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $flow.address,
                    action: {
                        tracker.track(.tap(action: .sendAddressScan),
                                      properties: [:])
                        self.flow.showScanView = true
                },
                    accessoryIcon: Image("QRCodeIcon")
                        .renderingMode(.original),
                    activeColor: recipientActiveColor,
                    onEditingChanged: { _ in },
                    onCommit: {
                        tracker.track(.tap(action: .sendAddressDoneAddress), properties: [:])
                }
                )
                    .onReceive(scanViewModel.addressPublisher, perform: { (address) in
                        self.flow.address = address
                        self.flow.showScanView = false
                    })
                    .sheet(isPresented: self.$flow.showScanView) {
                        NavigationView {
                            LazyView(
                                
                                ScanAddress(
                                    viewModel: self.scanViewModel,
                                    cameraAccess: CameraAccessHelper.authorizationStatus,
                                    isScanAddressShown: self.$flow.showScanView
                                ).environmentObject(ZECCWalletEnvironment.shared)
                                
                            )
                        }
                }
                if !ZECCWalletEnvironment.shared.isValidTransparentAddress(flow.address) {
                    ZcashMemoTextField(text: $flow.memo,
                                   includesReplyTo: $flow.includeSendingAddress,
                                   charLimit: .constant(charLimit))
                } else {
                    Spacer()
                }
                addressInBuffer
                    .onReceive(NotificationCenter.default.publisher(for: .addressSelection)) { (notification) in
                        let address = (notification.userInfo?["value"] as? String) ?? ""
                        self.flow.address = address
                        if !address.isEmpty {
                            tracker.track(.tap(action: .copyAddress), properties: [:])
                        }
                }
                
                NavigationLink(destination:
                    
                    Sending().environmentObject(flow)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true)
                    ,isActive: $sendOk
                ) {
                    EmptyView()
                }.isDetailLink(false)
                Spacer()
            }.padding([.horizontal,.bottom], 24)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .onAppear() {
            tracker.track(.screen(screen: .sendAddress), properties: [:])
        }
        .keyboardAdaptive()
        .animation(.easeInOut)
        .alert(isPresented: $showError) {
            alert(for: self.authError)
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }.onReceive(AuthenticationHelper.authenticationPublisher) { (output) in
            switch output {
            case .failed(_), .userFailed:
                self.authError = output
                self.showError = true
                
            // this error is not tracked on purpose.
            case .success:
                self.flow.includesMemo = true
                self.sendOk = true
            case .userDeclined:
                break
            }
        }
    }
    
    var includesMemo: Bool {
        !self.flow.memo.isEmpty || self.flow.includeSendingAddress
    }
    
    func alert(for authEvent: AuthenticationEvent) -> Alert {
        var title = "This is embarassing".localized()
        var message = "you shouldn't be seeing this".localized()
        
        switch authEvent {
        case .failed(let authError):
            title = "Authorization Failed!".localized()
            switch authError {
            case .authError(let localAuthError):
                message = localAuthError.localizedDescription
            case .generalError(let errorMessage):
                message = errorMessage
            case .unknown:
                message = "unknown error".localized()
            }
        case .userFailed:
            title = "Authorization Failed!".localized()
            message = "It appears that you were not able to authenticate".localized()
        default:
            break
        }
        
        return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("button_close")))
    }
}

struct SendTransaction_Previews: PreviewProvider {
    static var previews: some View {
        SendTransaction()
    }
}
