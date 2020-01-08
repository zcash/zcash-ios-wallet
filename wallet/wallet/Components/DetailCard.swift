//
//  DetailCard.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct DetailModel {
    
    enum Status {
        case paid
        case received
    }
    
    var zAddress: String
    var date: Date
    var zecAmount: Double
    var status: Status
    var shielded: Bool = true
    
}

final class DetailCardViewModel: ObservableObject {
    var model: DetailModel {
        didSet {
            setup()
        }
    }
    
    var title: String {
        
        switch model.status {
        case .paid:
            return "You paid \(model.zAddress)"
        case .received:
            return "\(model.shielded ? "Unknown" : model.zAddress) paid you"
            
        }
    }
    
    var showShield: Bool {
        model.shielded
    }
    
    var zecAmountColor: Color
    
    var zecAmount: String {
        model.zecAmount.toZecAmount() + " ZEC"
    }
    
    init(model: DetailModel) {
        self.model = model
        zecAmountColor = model.zecAmount < 0 ? Color.zNegativeZecAmount : Color.zPositiveZecAmount
    }
    
    func setup() {
        zecAmountColor = model.zecAmount < 0 ? Color.zNegativeZecAmount : Color.zPositiveZecAmount
        
    }
}


struct DetailCard: View {
 
    var viewModel: DetailCardViewModel
    var backgroundColor: Color = .black
    
    var shieldImage: AnyView {
        viewModel.showShield ? AnyView(Image("ic_shieldtick")) : AnyView(EmptyView())
    }
    var body: some View {
        ZStack {
            backgroundColor
            HStack {
                Spacer()
                StatusLine(status: viewModel.model.status)
                    .frame(width: 6.0)
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading){
                    HStack {
                        shieldImage
                        Text(viewModel.title)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .layoutPriority(0.5)
                         
                    }
                    Text("1 of 10 confirmations")
                        .font(.footnote)
                        .foregroundColor(.zLightGray2)
                        .opacity(0.4)
                    
                }
                .padding(.vertical, 8)
                Text(viewModel.zecAmount)
                    .foregroundColor(viewModel.zecAmountColor)
                .padding()
            }
            padding(8)
        }.cornerRadius(5)
        .frame(height: 69)
    }
    
}

struct StatusLine: View {
    var status: DetailModel.Status = .paid
    
    var body: some View {
        GeometryReader { geometry in
            
            Capsule(style: .circular)
                .size(geometry.size)
                .fill(
                    LinearGradient.gradient(for: self.status)
                )
        }
    }
}

extension LinearGradient {
    static func gradient(for cardType: DetailModel.Status) -> LinearGradient {
        
        switch cardType {
    
        default:
            return LinearGradient(
                       gradient: Gradient.paidCard,
                       startPoint: UnitPoint(x: 0.3, y: 0.0),
                       endPoint: UnitPoint(x: 0.5, y: 0.5)
            )
        }
    }
}


struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground.amberGradient
            VStack {
                DetailCard(viewModel:
                    DetailCardViewModel(model: DetailModel(
                            zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                            date: Date(),
                            zecAmount: -12.345,
                            status: .paid
                            )
                    )
                )
                .padding()
            }
        }
    }
}
