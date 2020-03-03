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
extension Notification.Name {
    static let qrZaddressScanned = Notification.Name(rawValue: "qrZaddressScanned")
}

class ScanAddressViewModel: ObservableObject {
    var scannerDelegate: QRScannerViewDelegate
    var dispose = Set<AnyCancellable>()
    
    init(delegate: CombineAdapter = CombineAdapter()) {
        self.scannerDelegate = delegate
        delegate.publisher.sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                print("error: \(error)")
            case .finished:
                print("finished")
            }
        }) { (address) in
            NotificationCenter.default.post(Notification(name: .qrZaddressScanned, object: self, userInfo: ["zAddress" : address]))
        }.store(in: &dispose)
    }
    
    init(address: Binding<String>, shouldShow: Binding<Bool>) {
        
        self.scannerDelegate = BindingAdapter(address: address, shouldShow: shouldShow)
    }
}

struct ScanAddress: View {
    @EnvironmentObject var environment: ZECCWalletEnvironment
    
    @State var cameraAccess: CameraAccessHelper.Status = CameraAccessHelper.authorizationStatus
    
    @ObservedObject var viewModel = ScanAddressViewModel()
    
    var scanFrame: some View {
        Image("QRCodeScanFrame")
            .padding()
    }
    
    var authorized: some View {
        Group {
            QRCodeScannerView(delegate: viewModel.scannerDelegate)
                .edgesIgnoringSafeArea(.all)
                
            VStack {
                Spacer()
                scanFrame
                Spacer()
                switchButton
                
            }
            .navigationBarItems(
                trailing: Button(action: {
                    print("toggle flashlight")
                }) {
                    Image("bolt")
                        .renderingMode(.template)
                }
            )
            
        }
    }
    
    var unauthorized: some View {
        Group {
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
        Group {
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
    
    var switchButton: some View {
        
       Button(action: {}) {
           ZStack {
               ZcashChamferedButtonBackground(cornerTrim: 10)
                   .fill(Color.white)
               
               VStack {
                   
                   Image("zcash_icon_black")
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
    }
    
    func viewFor(state: CameraAccessHelper.Status) -> some View {
        switch state {
        case .authorized, .undetermined:
            return AnyView(authorized)
        case .unauthorized:
            return AnyView(unauthorized)
        case .unavailable:
            return AnyView(restricted)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                viewFor(state: cameraAccess)
            }
            .navigationBarTitle("Scan Recipient Address", displayMode: .inline)
        }
    }
}

struct ScanAddress_Previews: PreviewProvider {
    static var previews: some View {
        ScanAddress(cameraAccess: .unavailable)
        .environmentObject(ZECCWalletEnvironment.shared)
    }
}
