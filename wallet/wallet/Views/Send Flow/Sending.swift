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
    @State var showHistory: Bool = false
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
            return Text("Unable to send")
        }
        
        return flow.isDone ? Text("send_sent") :     Text(String(format: NSLocalizedString("send_sending", comment: ""), flow.amount))
    }
    
    var includesMemoView: AnyView {
        guard flow.includesMemo else { return AnyView(EmptyView()) }
        return  AnyView(
            HStack {
                ZcashCheckCircle(isChecked: .constant(flow.includesMemo),externalRingColor: .clear, backgroundColor: .black)
                    .disabled(true)
                Text("Includes memo")
                    .foregroundColor(.black)
                    .font(.footnote)
            }
        )
    }
    
    var doneButton: AnyView {
        guard flow.isDone else { return AnyView(EmptyView()) }
        return AnyView(
            Text("button_done")
                .foregroundColor(.black)
                .frame(height: 58)
        )
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
                includesMemoView
                if !flow.isDone {
                    loading
                        .frame(height: 48)
                    
                }
                Spacer()
                if self.flow.isDone {
                    VStack {
                        Button(action: {
                            tracker.track(.tap(action: .sendFinalDetails), properties: [:])
                            self.showHistory = true
                        }) {
                            Text("button_seedetails")
                                .foregroundColor(.black)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: Color.black, lineWidth: 2)))
                                .frame(height: 58)
                        }
                        NavigationLink(destination: WalletDetails(isActive: $showHistory)
                            .environmentObject(WalletDetailsViewModel())
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarHidden(true),
                                       isActive: $showHistory) {
                                        EmptyView()
                        }.isDetailLink(false)
                    }
                }
                
                Button(action: {
                    tracker.track(.tap(action: .sendFinalClose), properties: [:])
                    self.flow.close()
                }) {
                    doneButton
                }
                
            }
            .padding([.horizontal, .bottom], 40)
            
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
