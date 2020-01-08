//
//  Sending.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct Sending: View {
    var zAddress: String
    var includesMemo: Bool
    var zecAmount: Double
    
    var detailCardModel: DetailModel?
    @State var isDone = false
    
    var includesMemoView: AnyView {
        guard includesMemo else { return AnyView(EmptyView()) }
        return  AnyView(
            HStack {
                ZcashCheckCircle(isChecked: .constant(includesMemo),externalRingColor: .clear, backgroundColor: .black)
                    .disabled(true)
                Text("Includes memo")
                    .foregroundColor(.black)
                    .font(.footnote)
            }
        )
    }
    
    var doneButton: AnyView {
        guard isDone else { return AnyView(EmptyView()) }
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
        isDone ? sendPastTense : sendGerund
    }
    
    var card: AnyView {
        guard let model = detailCardModel else { return AnyView(EmptyView()) }
        return AnyView(
            DetailCard(viewModel:
                DetailCardViewModel(model: model)
            )
        )
        
    }
    var body: some View {
        ZStack {
            ZcashBackground.amberGradient
            
            VStack(alignment: .center) {
                Spacer()
                Text("\(send) \(zecAmount.toZecAmount()) ZEC to")
                    .foregroundColor(.black)
                    .font(.title)
                Text("\(zAddress)")
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
        Sending(zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6", includesMemo: true, zecAmount: 12.345, detailCardModel: DetailModel(
            zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
            date: Date(),
            zecAmount: -12.345,
            status: .paid
        ), isDone: true)
    }
}
