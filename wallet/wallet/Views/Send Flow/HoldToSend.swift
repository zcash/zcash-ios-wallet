//
//  HoldToSend.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct HoldToSend: View {
    @EnvironmentObject var flow: SendFlowEnvironment
    
    var networkFee: Double = 0.0001
    var pressAndHoldSeconds: TimeInterval = 3
    @State var holdOk = false
    
    var includesMemoView: AnyView {
        guard flow.includesMemo else { return AnyView(EmptyView()) }
        return  AnyView(
            HStack {
                ZcashCheckCircle(isChecked: .constant(flow.includesMemo))
                    .disabled(true)
                Text("Includes memo")
                    .foregroundColor(.white)
                    .font(.footnote)
            }
        )
    }
    
    var body: some View {
        ZStack {
            ZcashBackground()
            
            VStack(alignment: .center) {
                Spacer()
                Text("Send %@ ZEC to".localized(with: "\(flow.amount)"))
                    .foregroundColor(.white)
                    .font(.title)
                Text("\(flow.address)?")
                    .truncationMode(.middle)
                    .foregroundColor(.white)
                    .font(.title)
                    .lineLimit(1)
                includesMemoView
                Spacer()
                ZcashHoldToSendButton(minimumDuration: pressAndHoldSeconds, longPressCancelled: {
                    logger.debug("long press cancelled")
                }, longPressSucceded: {
                    logger.debug("long press succeded")
                    self.holdOk = true
                }, longPressStarted: {
                    logger.debug("long press started")
                })
                    
                
                NavigationLink(destination:
                    
                    Sending().environmentObject(flow)
                    .navigationBarTitle("", displayMode: .inline)
                    .navigationBarBackButtonHidden(true)
                    ,
                    
                        isActive: $holdOk
                    ) {
                        EmptyView()
                    }.isDetailLink(false)
                
                Spacer()
                
                Text("Network fee: %@".localized(with: "\(networkFee.toZecAmount())" ))
                    .font(.footnote)
                    .foregroundColor(Color.zLightGray2)
                    .opacity(0.46)
                
                Spacer()
            }
            .padding([.horizontal], 40)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: ZcashCloseButton(action: {
            self.flow.close()
            }).frame(width: 30, height: 30))
    }
}
//
//struct HoldToSend_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        let flow: SendFlowEnvironment = SendFlowEnvironment(amount: 1.2345, verifiedBalance: 23.456, isActive: .constant(true))
//        
//        flow.address = "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
//        return HoldToSend().environmentObject(flow)
//    }
//}
