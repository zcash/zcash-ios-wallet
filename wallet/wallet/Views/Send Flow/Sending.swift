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
    
    var errorMessage: String {
        guard let e = flow.error else {
            return "thing is that we really don't know what just went down, sorry!"
        }
        
        return "\(e)"
    }
    var sendGerund: String {
        "Sending"
    }
    
    var sendPastTense: String {
        "Sent"
    }
    
    var showErrorAlert: Alert {
        var errorMessage = "an error ocurred while submitting your transaction"
        
        if let error = self.flow.error {
            errorMessage = "\(ZECCWalletEnvironment.mapError(error: error) )"
        }
        return Alert(title: Text("Error"),
              message: Text(errorMessage),
              dismissButton: .default(
                Text("close"),
                action: {
                    self.flow.isActive = false
                    
              }
            )
        )
    }
    
    var sendText: String {
        guard flow.error == nil else {
            return "Unable to send"
        }
        
        return flow.isDone ? sendPastTense : sendGerund
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
            ZcashButton(
                color: Color.black,
                fill: Color.zYellow,
                text: "All Done!"
            )
                .frame(height: 58)
                .padding([.leading, .trailing], 30)
        )
    }
    
    
    
    var card: AnyView {
        guard let pendingTx = flow.pendingTx else {
            return AnyView(EmptyView())
        }
        return AnyView(
            DetailCard(model: DetailModel(pendingTransaction: pendingTx))
            .padding()
            .frame(height: 69)
        )
    }
    
    var body: some View {
        ZStack {
            ZcashBackground.amberGradient
            VStack(alignment: .center) {
                Spacer()
                Text("\(sendText) \(flow.amount) ZEC to")
                    .foregroundColor(.black)
                    .font(.title)
                Text("\(flow.address)")
                    .truncationMode(.middle)
                    .foregroundColor(.black)
                    .font(.title)
                    .lineLimit(1)
                includesMemoView
                Spacer()
                Button(action: {
                    self.flow.isActive = false
                }) {
                    doneButton
                }
                card
                Spacer()
            }.padding([.horizontal], 40)
            
        }.navigationBarItems(trailing: Button(action: {
            self.flow.isActive = false
        }) {
            Image("close")
                .renderingMode(.original)
        }.disabled(self.flow.isDone)
            .opacity(self.flow.isDone ? 1.0 : 0.0)
        )
        .alert(isPresented: self.$flow.showError) {
                showErrorAlert
        }
        .onAppear() {
                self.flow.send()
        }
    }
}

struct Sending_Previews: PreviewProvider {
    static var previews: some View {
        
        let flow = SendFlowEnvironment(amount: 1.234, verifiedBalance: 23.456, isActive: .constant(true))
        flow.address = "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        flow.includesMemo = true
        flow.isDone = false
        return Sending().environmentObject(flow)
    }
}
