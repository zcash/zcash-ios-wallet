//
//  Sending.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import ZcashLightClientKit

struct Sending: View {
    
    @EnvironmentObject var flow: SendFlowEnvironment
    @State var details: DetailModel? = nil
    
    var loading = LottieAnimation(filename: "lottie_sending")
    var errorMessage: String {
        guard let e = flow.error else {
            return "thing is that we really don't know what just went down, sorry!"
        }
        
        return "\(e)"
    }
 
    var showErrorAlert: Alert {
        var errorMessage = "an error ocurred while submitting your transaction"
        
        if let error = self.flow.error {
            errorMessage = "\(ZECCWalletEnvironment.mapError(error: error) )"
        }
        return Alert(title: Text("Error"),
                     message: Text(errorMessage),
                     dismissButton: .default(
                        Text("button_close"),
                        action: {
                            self.flow.close()
                            
                     }
            )
        )
    }
    
    var sendText: some View {
        guard flow.error == nil else {
            return Text("label_unabletosend")
        }
        
        return flow.isDone ? Text("send_sent") :     Text(String(format: NSLocalizedString("send_sending", comment: ""), flow.amount))
    }
    
    var body: some View {
        ZStack {
            ZcashBackground.amberGradient
            VStack(alignment: .center, spacing: 40) {
                Spacer()
                sendText
                    .foregroundColor(.black)
                    .font(.title)
                Text("\(flow.address)")
                    .truncationMode(.middle)
                    .foregroundColor(.black)
                    .font(.title)
                    .lineLimit(1)
                
                if !flow.isDone {
                    loading
                        .frame(height: 48)
                    
                }
                Spacer()
                if self.flow.isDone && self.flow.pendingTx != nil {
                    Button(action: {
                        guard let pendingTx = self.flow.pendingTx  else {
                            tracker.report(handledException: DeveloperFacingErrors.unexpectedBehavior(message: "Attempt to open transaction details in sending screen with no pending transaction in send flow"))
                            tracker.track(.error(severity: .warning), properties: [ErrorSeverity.messageKey : "Attempt to open transaction details in sending screen with no pending transaction in send flow"])
                            self.flow.close() // close this so it does not get stuck here
                            return
                        }
                        
                        let latestHeight = ZECCWalletEnvironment.shared.synchronizer.syncBlockHeight.value
                        self.details = DetailModel(pendingTransaction: pendingTx,latestBlockHeight: latestHeight)
                        tracker.track(.tap(action: .sendFinalDetails), properties: [:])
                        
                    }) {
                        Text("button_seedetails")
                            .foregroundColor(.black)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: Color.black, lineWidth: 2)))
                            .frame(height: 58)
                    }
                }
                
                if flow.isDone {
                    Button(action: {
                        tracker.track(.tap(action: .sendFinalClose), properties: [:])
                        self.flow.close()
                    }) {
                        Text("button_done")
                            .foregroundColor(.black)
                            .frame(height: 58)
                    }
                }
            }
            .padding([.horizontal, .bottom], 40)
        }
        .sheet(item: $details, onDismiss: { self.flow.close() }){ item in
            TxDetailsWrapper(row: item)
        }
        .alert(isPresented: self.$flow.showError) {
            showErrorAlert
        }
        .onAppear() {
            tracker.track(.screen(screen: .sendFinal), properties: [:])
            self.loading.play(loop: true)
            self.flow.send()
        }
    }
}
