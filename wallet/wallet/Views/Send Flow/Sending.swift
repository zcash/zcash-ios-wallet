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
final class SendingViewModel: ObservableObject {
    
    var diposables = Set<AnyCancellable>()
    weak var flow: SendFlowEnvironment?
    var showError = false
    var pendingTx: PendingTransactionEntity?
    var error: Error?
    
    var errorMessage: String {
        guard let e = error else {
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
    
    var sendText: String {
        guard let flow = self.flow, self.error == nil  else {
            return "Unable to send"
        }
        
        return flow.isDone ? sendPastTense : sendGerund
    }
    
    func send() {
        self.flow?.send()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] (completion) in
                switch completion {
                case .finished:
                    self?.flow?.isDone = true
                case .failure(let error):
                    print("error: \(error)")
                    self?.error = error
                    self?.showError = true
                }
            }) { [weak self] (transaction) in
                self?.pendingTx = transaction
        }.store(in: &diposables)
    }
}
struct Sending: View {
    
    @EnvironmentObject var flow: SendFlowEnvironment
    
    @ObservedObject var viewModel = SendingViewModel()
    
    var includesMemoView: AnyView {
        guard flow.includesMemo else { return AnyView(Divider()) }
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
        guard let pendingTx = viewModel.pendingTx else {
            return AnyView(EmptyView())
        }
        return AnyView(
            DetailCard(model: DetailModel(pendingTransaction: pendingTx))
        )
    }
    
    var body: some View {
        ZStack {
            ZcashBackground.amberGradient
            
            VStack(alignment: .center) {
                Spacer()
                Text("\(viewModel.sendText) \(flow.amount) ZEC to")
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
                
            }.padding([.horizontal], 40)
                .alert(isPresented: self.$viewModel.showError) {
                    Alert(
                        title: Text("Something happened!"),
                        message: Text(self.viewModel.errorMessage),
                        dismissButton: .default(Text("dismiss"),
                                                action: {
                                                    self.flow.isActive = false
                        })
                    )
            }
        }.navigationBarItems(trailing: Button(action: {
            self.flow.isActive = false
        }) {
            Image("close")
                .renderingMode(.original)
        }.disabled(self.viewModel.error != nil || !self.flow.isDone))
            .onAppear() {
                self.viewModel.flow = self.flow
                self.viewModel.send()
        }
    }
}

struct Sending_Previews: PreviewProvider {
    static var previews: some View {
        
        let flow = SendFlowEnvironment(amount: 1.234, verifiedBalance: 23.456, isActive: .constant(true))
        flow.address = "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        flow.includesMemo = true
        flow.isDone = false
        return Sending()
    }
}
