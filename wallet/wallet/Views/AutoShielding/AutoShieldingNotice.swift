//
//  AutoShieldingNotice.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 6/28/21.
//  Copyright © 2021 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct AutoShieldingNotice: View {
    var confirmAction: () -> ()
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 60) {
                Image("ic_shieldtick_yellow")
                
                VStack(alignment: .center, spacing: 40) {
                subtitle
                    .foregroundColor(.zLightGray2)
                    .font(.system(size: 20))
                    .lineLimit(12)
                    .multilineTextAlignment(.center)
                firstParagraph
                    .foregroundColor(.zLightGray2)
                    .multilineTextAlignment(.center)
                secondParagraph
                    .foregroundColor(.zLightGray2)
                    .multilineTextAlignment(.center)
                }
                
                buttons
                    .frame(alignment: .bottom)
            }
            .padding(.horizontal, 30)
        }
        .onAppear() {
            tracker.track(.screen(screen: .autoShieldNotice), properties: [:])
        }
    }
    
    @ViewBuilder var subtitle: some View {
        Text("We now ") +
        Text("shield by default")
            .bold() +
            Text(". This is to ensure maximum privacy.")
    }
    
    @ViewBuilder var firstParagraph: some View {
        Text("Autoshielding ")
            .bold() +
            Text("means any funds coming to your transparent address will automatically be moved to your shielded wallet.")
    }
    
    @ViewBuilder var secondParagraph: some View {
        Text("We'll always update you on the latest privacy-preserving best practices and recommendations.")
    }
    
    @ViewBuilder var buttons: some View {
        VStack(alignment: .center, spacing: 8, content: {
            Button(action: {
                confirmAction()
            }, label: {
                Text("Awesome, Do it!")
                    .foregroundColor(.black)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: .zYellow)))
                    .frame(height: 48, alignment: .center)
            })
            
        })
        .padding(0)
    }
}

struct AutoShieldingNotice_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AutoShieldingNotice(confirmAction: {})
                .previewDevice("iPhone 8")
            AutoShieldingNotice(confirmAction: {})
                .previewDevice("iPhone 11")
            AutoShieldingNotice(confirmAction: {})
                .previewDevice("iPhone 11 Pro Max")
        }
    }
}
