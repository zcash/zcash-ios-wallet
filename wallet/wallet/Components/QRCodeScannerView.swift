//
//  QRCodeScannerView.swift
//  wallet
//
//  Created by Francisco Gindre on 2/4/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import TinyQRScanner
import Combine

public class BindingAdapter: QRScannerViewDelegate {
    
    @Binding var address: String
    @Binding var shouldShow: Bool
    
    init(address: Binding<String>, shouldShow: Binding<Bool>) {
        self._address = address
        self._shouldShow = shouldShow
    }
    
    public func qrScanningDidFail() {
        self.shouldShow = false
    }
    
    public func qrScanningSucceededWithCode(_ str: String?) {
        guard let string = str else {
            return
        }
        
        address = string
        shouldShow = false
        
    }
    
    public func qrScanningDidStop() {
        shouldShow = false
    }
    
}
public class CombineAdapter: QRScannerViewDelegate {
    
    public enum TinyQRScannerError: Error {
        case scanningFailed
        case emptyCode
    }
    public var publisher = PassthroughSubject<String,TinyQRScannerError>()
    
    public func qrScanningDidFail() {
        publisher.send(completion: .failure(.scanningFailed))
    }
    
    public func qrScanningSucceededWithCode(_ str: String?) {
        guard let code = str else {
            publisher.send(completion: .failure(.emptyCode))
            return
        }
        publisher.send(code)
    }
    
    public func qrScanningDidStop() {
        publisher.send(completion: .finished)
    }
    
    
}
public struct QRCodeScannerView: UIViewRepresentable {
    
    var delegate: QRScannerViewDelegate = CombineAdapter()
    
    
    public func makeUIView(context: UIViewRepresentableContext<QRCodeScannerView>) -> QRScannerView {
        let view = QRScannerView()
        view.continueVideoSessionAfterScanning = true
        view.delegate = delegate
        return view
    }
    
    public func updateUIView(_ uiView: QRScannerView, context: UIViewRepresentableContext<QRCodeScannerView>) {
    }
    
    public typealias UIViewType = QRScannerView
    
    
}

struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerView()
    }
}
