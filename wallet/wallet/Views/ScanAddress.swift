//
//  ScanAddress.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import TinyQRScanner
import AVFoundation
extension Notification.Name {
    static let qrZaddressScanned = Notification.Name(rawValue: "qrZaddressScanned")
}

class ScanAddressViewModel: ObservableObject {
    var scannerDelegate: QRScannerViewDelegate
    var dispose = Set<AnyCancellable>()
    var shouldShowSwitchButton: Bool = true
    var showCloseButton: Bool = false
    init(shouldShowSwitchButton: Bool, showCloseButton: Bool, delegate: CombineAdapter = CombineAdapter()) {
        self.shouldShowSwitchButton = shouldShowSwitchButton
        self.showCloseButton = showCloseButton
        self.scannerDelegate = delegate
        delegate.publisher.sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                logger.error("\(error)")
            case .finished:
                logger.debug("finished")
            }
        }) { (address) in
            NotificationCenter.default.post(Notification(name: .qrZaddressScanned, object: self, userInfo: ["zAddress" : address]))
        }.store(in: &dispose)
    }
    
    init(shouldShowSwitchButton: Bool, showCloseButton: Bool, address: Binding<String>, shouldShow: Binding<Bool>) {
        self.shouldShowSwitchButton = shouldShowSwitchButton
        self.showCloseButton = showCloseButton
        self.scannerDelegate = BindingAdapter(address: address, shouldShow: shouldShow)
    }
}

struct ScanAddress: View {
    @EnvironmentObject var environment: ZECCWalletEnvironment
    
    @ObservedObject var viewModel: ScanAddressViewModel
    @State var cameraAccess: CameraAccessHelper.Status
    @Binding var isScanAddressShown: Bool
    
    @State var torchEnabled: Bool = false
    
//    init(scanViewModel: ScanAddressViewModel,
//         cameraStatus: CameraAccessHelper.Status,
//         isShown: Binding<Bool>,
//         showCloseButton: Bool,
//         showSwitchButton: Bool) {
//        self.viewModel = scanViewModel
//        self.cameraAccess = cameraStatus
//        self._isScanAddressShown = isShown
//        self.showCloseButton = showCloseButton
//        self.shouldShowSwitchButton = showSwitchButton
//    }
//
    var scanFrame: some View {
        Image("QRCodeScanFrame")
            .padding()
    }
    
    var torchButton: AnyView {
        guard torchAvailable else { return AnyView(EmptyView()) }
        return AnyView(
            Button(action: {
                self.toggleTorch(on: !self.torchEnabled)
                self.torchEnabled.toggle()
            }) {
                Image("bolt")
                    .renderingMode(.template)
            }
        )
    }
    
    var authorized: some View {
          ZStack {
            QRCodeScannerView(delegate: viewModel.scannerDelegate)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                scanFrame
                Spacer()
                switchButton
                
            }
        }
    }
    
    var unauthorized: some View {
         ZStack {
            ZcashBackground()
            VStack {
                Spacer()
                ZStack {
                    scanFrame
                    Text("We don't have permission to access your camera")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.all, 36)
                }
                Spacer()
                
                Button(action: {}){
                    ZcashButton(text: "Request Camera Access")
                        .frame(height: 50)
                }
                .padding()
                
                switchButton
                
            }
            
        }
    }
    
    var restricted: some View {
          ZStack {
            ZcashBackground()
            VStack {
                Spacer()
                ZStack {
                    scanFrame
                    Text("Camera Unavailable")
                        .foregroundColor(.white)
                }
                Spacer()
                switchButton 
            }
        }
    }
    
    var switchButton:  AnyView {
        guard viewModel.shouldShowSwitchButton else { return AnyView (EmptyView()) }
        return AnyView(
            Button(action: {
                self.isScanAddressShown = false
            }) {
                ZStack {
                    ZcashChamferedButtonBackground(cornerTrim: 10)
                        .fill(Color.white)
                    
                    VStack {
                        
                        Image("zcash_icon_black_small")
                            .renderingMode(.original)
                            .frame(width: 50, height: 50)
                        Text("Switch to your Zcash address")
                            .foregroundColor(.black)
                    }
                    .scaledToFit()
                }
            }
            .frame(height: 158)
            .padding()
        )
    }
    
    func viewFor(state: CameraAccessHelper.Status) -> some View {
        switch state {
        case .authorized, .undetermined:
            let auth = authorized.navigationBarTitle("Scan Recipient Address", displayMode: .inline)
            
            if viewModel.showCloseButton {
                return AnyView(
                    auth.navigationBarItems(leading: torchButton, trailing:  ZcashCloseButton(action: { self.isScanAddressShown = false }).frame(width: 30, height: 30))
                )
            }
            return AnyView(
                auth.navigationBarItems(
                    trailing: torchButton
                )
            )
        case .unauthorized:
            return AnyView(unauthorized)
        case .unavailable:
            return AnyView(restricted)
        }
    }
    
    var body: some View {
        viewFor(state: cameraAccess)
        .onDisappear() {
            self.toggleTorch(on: false)
        }
    }
    
    private var torchAvailable: Bool {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false}
        return device.hasTorch
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { logger.info("Torch isn't available"); return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            // Optional thing you may want when the torch it's on, is to manipulate the level of the torch
            if on { try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel) }
            device.unlockForConfiguration()
        } catch {
            logger.info("Torch can't be used")
        }
    }
}
//
//struct ScanAddress_Previews: PreviewProvider {
//    static var previews: some View {
//        ScanAddress(isShown: .constant(false), showCloseButton: false, showSwitchButton: <#Bool#>)
//            .environmentObject(ZECCWalletEnvironment.shared)
//    }
//}
