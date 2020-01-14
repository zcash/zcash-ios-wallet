//
//  Sending.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct Sending: View {
    
    @EnvironmentObject var flow: SendFlowEnvironment
    
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
    
    var sendGerund: String {
        "Sending"
    }
    
    var sendPastTense: String {
        "Sent"
    }
    
    var send: String {
        flow.isDone ? sendPastTense : sendGerund
    }
    
    var card: AnyView {
       AnyView(EmptyView())
    }
    
    var body: some View {
        ZStack {
            ZcashBackground.amberGradient
            
            VStack(alignment: .center) {
                Spacer()
                Text("\(send) \(flow.amount) ZEC to")
                    .foregroundColor(.black)
                    .font(.title)
                Text("\(flow.address)")
                    .truncationMode(.middle)
                    .foregroundColor(.black)
                    .font(.title)
                    .lineLimit(1)
                includesMemoView
                Spacer()
                doneButton
                card
                
            }.padding([.horizontal], 40)
        }
    }
}

struct Sending_Previews: PreviewProvider {
    static var previews: some View {
        
        let flow = SendFlowEnvironment(amount: 1.234, verifiedBalance: 23.456)
        flow.address = "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        flow.includesMemo = true
        flow.isDone = false
        return Sending()
    }
}
