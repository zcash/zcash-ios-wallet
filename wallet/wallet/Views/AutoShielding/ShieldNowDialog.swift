//
//  ShieldNowDialog.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 7/1/21.
//  Copyright © 2021 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct ShieldNowDialog: View {
    var confirmBlock: () -> ()
    var dismissBlock: () -> ()
    var threshold: Int64 = ZECCWalletEnvironment.autoShieldingThresholdInZatoshi
    var body: some View {
            ZStack {
            
                Color.zGray
                        .cornerRadius(20)

                VStack(alignment: .center, spacing: 30) {
                    image
                    title
                    receivedText(shieldingThreshold: ZECCWalletEnvironment.thresholdInZec, unit: .ZEC)
                    buttons
                }
                .padding(20)
            }
    }
    
    @ViewBuilder var image: some View {
        ZStack {
            Image("ic_shieldtick_yellow")
//            Text("?")
//                .foregroundColor(.black)
//                .font(.system(size: 48))
        }
    }
    @ViewBuilder var title: some View {
        Text("Shield Now?")
            .foregroundColor(.white)
            .font(.largeTitle)
    }
    
    @ViewBuilder func receivedText(shieldingThreshold: String, unit: String) -> some View {
        Text("""
             You've received more than \(shieldingThreshold) \(unit) in transparent funds.
             
             Mind if we interrupt to shield?
             """)
            .foregroundColor(.white)
            .font(.system(size: 18, weight: .light, design: .default))
            .opacity(0.7)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder var buttons: some View {
        VStack(alignment: .center, spacing: 16) {
            Button(action: {
                confirmBlock()
            }, label: {
                Text("Shield Now")
                    .foregroundColor(.black)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: .white)))
            })
            .frame(height: 48, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Button(action: {
                dismissBlock()
            }, label: {
                Text("Do it later")
                    .foregroundColor(.zGray2)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .zGray2, lineWidth: 2)))
            })
            .frame(height: 48, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ShieldNowDialog_Previews: PreviewProvider {
    static var previews: some View {
        ShieldNowDialog(confirmBlock: {}, dismissBlock: {})
    }
}
