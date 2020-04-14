//
//  DetailCard.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct DetailModel: Identifiable {
    
    enum Status {
        case paid(success: Bool)
        case received
    }
    var id: String
    var zAddress: String?
    var date: Date
    var zecAmount: Double
    var status: Status
    var shielded: Bool = true
    var memo: String? = nil
    var title: String {

        switch status {
        case .paid(let success):
            return success ? "You paid \(zAddress?.shortZaddress ?? "Unknown")" : "Unsent Transaction"
        case .received:
            return "\(zAddress?.shortZaddress ?? "Unknown") paid you"
        }
    }
    
    var subtitle: String
    
}

//final class DetailCardViewModel {
//    var model: DetailModel
//
//    var title: String {
//
//        switch model.status {
//        case .paid:
//            return "You paid \(model.zAddress)"
//        case .received:
//            return "\(model.shielded ? "Unknown" : model.zAddress) paid you"
//
//        }
//    }
//
//    var showShield: Bool {
//        model.shielded
//    }
//
//    var zecAmountColor: Color
//
//    var zecAmount: String {
//        model.zecAmount.toZecAmount() + " ZEC"
//    }
//
//    init(model: DetailModel) {
//        self.model = model
//        zecAmountColor = model.zecAmount < 0 ? Color.zNegativeZecAmount : Color.zPositiveZecAmount
//    }
//
//    func setup() {
//        zecAmountColor = model.zecAmount < 0 ? Color.zNegativeZecAmount : Color.zPositiveZecAmount
//
//    }
//}


struct DetailCard: View {
 
    var model: DetailModel
    var backgroundColor: Color = .black
    
    var shieldImage: AnyView {
        
        let view = model.shielded ? AnyView(Image("ic_shieldtick")) : AnyView(EmptyView())
        switch model.status {
        case .paid(let success):
            return success ? view : AnyView(EmptyView())
        default:
            return view
        }
        
    }
    
    var zecAmount: AnyView {
        let amount = model.zecAmount.toZecAmount()
        var text = ((model.zecAmount > 0) ? "+ " : "") +  amount + " ZEC"
        var color = Color.zPositiveZecAmount
        var opacity = Double(1)
        switch model.status {
        case .paid(let success):
            color = success ? Color.zNegativeZecAmount : Color.zLightGray2
            opacity = success ? 1 : 0.6
            
            text = success ? text : "(\(amount) ZEC)"
            
        default:
            break
        }
        
        
        return AnyView(
            Text(text)
                .foregroundColor(color)
                .opacity(opacity)
            )
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            HStack {
                StatusLine(status: model.status)
                    .frame(width: 3.0)
                    .padding(.vertical, 8)

                VStack(alignment: .leading){
                    HStack {
                        shieldImage
                        Text(model.title)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .layoutPriority(0.5)

                    }
                    Text(model.subtitle)
                        .font(.body)
                        .foregroundColor(.zLightGray2)
                        .opacity(0.6)
                }
                .padding(.vertical, 8)
                Spacer()
                zecAmount
               
            }
            
        }.cornerRadius(5)
        
    }
    
}

struct StatusLine: View {
    var status: DetailModel.Status = .paid(success: true)
    
    var opacity: Double {
        var _opacity = Double(1)
        switch status {
        case .paid(let success):
            if !success {
                _opacity = 0.6
            }
        default:
            break
        }
        return _opacity
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            Capsule(style: .circular)
                .size(geometry.size)
                .fill(
                    LinearGradient.gradient(for: self.status)
                )
                .opacity(self.opacity)
        }
    }
}

extension LinearGradient {
    static func gradient(for cardType: DetailModel.Status) -> LinearGradient {
        var gradient = Gradient.paidCard
        switch cardType {
    
        case .paid(let success):
            gradient = success ? Gradient.paidCard : Gradient.failedCard
        case .received:
            gradient = Gradient.receivedCard
        }
        return LinearGradient(
            gradient: gradient,
            startPoint: UnitPoint(x: 0.3, y: 0.7),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }
}


struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
                DetailCard(model:
                    DetailModel(
                        id: "bb031",
                            zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                            date: Date(),
                            zecAmount: -12.345,
                            status: .paid(success: true),
                            subtitle: "1 of 10 confirmations"
                            )
                    )
                    .padding()
            
            
            DetailCard(model:
            DetailModel(
                id: "bb032",
                    zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                    date: Date(),
                    zecAmount: 2.0,
                    status: .received,
                    subtitle: "Received 11/16/19 4:12pm"
                    )
            )
            
            DetailCard(model:
            DetailModel(
                id: "bb033",
                    zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                    date: Date(),
                    zecAmount: 2.0,
                    status: .paid(success: false),
                    subtitle: "Received 11/16/19 4:12pm"
                    )
            )
        }.previewLayout(.fixed(width: 360, height: 69))
    }
}
