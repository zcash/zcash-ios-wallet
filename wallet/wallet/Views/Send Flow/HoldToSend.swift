//
//  HoldToSend.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct HoldToSend: View {
    
    var zAddress: String
    var includesMemo: Bool
    var zecAmount: Double
    var networkFee: Double = 0.0001
    var pressAndHoldSeconds: TimeInterval = 5
    @State var holdOk = false
    var includesMemoView: AnyView {
        guard includesMemo else { return AnyView(EmptyView()) }
        return  AnyView(
            HStack {
                ZcashCheckCircle(isChecked: .constant(includesMemo))
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
                Text("Send \(zecAmount.toZecAmount()) ZEC to")
                    .foregroundColor(.white)
                    .font(.title)
                Text("\(zAddress)?")
                    .truncationMode(.middle)
                    .foregroundColor(.white)
                    .font(.title)
                    .lineLimit(1)
                includesMemoView
                Spacer()
                ZStack{
                    Text("Press and hold\nto send ZEC")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    
                }
                .frame(
                    width: 167,
                    height: 167,
                    alignment: .center
                )
                .padding()
                .onLongPressGesture(minimumDuration: 5, maximumDistance: 10, pressing: { (isPressing) in
                    print("isPressing \(isPressing)")
                }, perform: {
                    print("long pressed!!!")
                    self.holdOk = true
                })
                
                NavigationLink(destination:
                        Sending(zAddress: zAddress, includesMemo: includesMemo, zecAmount: zecAmount, detailCardModel: DetailModel(
                        zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        zecAmount: -12.345,
                        status: .paid
                        ), isDone: false),isActive: $holdOk
                ) {
                    EmptyView()
                }
                
                Spacer()
                
                Text("Network fee: \(networkFee.toZecAmount())")
                    .font(.footnote)
                    .foregroundColor(Color.zLightGray2)
                    .opacity(0.46)
                
                Spacer()
            }
            .padding([.horizontal], 40)
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct HoldToSend_Previews: PreviewProvider {
    static var previews: some View {
        HoldToSend(zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6", includesMemo: true, zecAmount: 12.345)
    }
}
