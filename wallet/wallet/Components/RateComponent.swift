//
//  RateComponent.swift
//  wallet
//
//  Created by Francisco Gindre on 7/14/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct RateComponent: View {
    @Binding var selectedIndex: Int
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(1 ..< 6) { index in
                Toggle(isOn: .constant(self.selectedIndex == index)) {
                    Text(String(index))
                        .font(Font.zoboto(size: 28))
                        .foregroundColor(.black)
                }.toggleStyle(RatingToggleStyle(
                    shape: Circle(),
                    padding: 20,
                    action: {
                        self.selectedIndex = index
                })
                )
                
            }
        }
    }
}


struct RatingToggleStyle<S :Shape>: ToggleStyle {
    let shape: S
    var padding: CGFloat = 8
    var action = {}
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack(alignment: .center) {
            Button(action: {
                configuration.isOn.toggle()
                self.action()
            }) {
                configuration.label
                    .contentShape(shape)
                    .frame(width: 50, height: 50, alignment: .center)
            }
            .background(
                SimpleRateBackground(isHighlighted: configuration.isOn, shape: shape)
            )
        }
    }
}

struct SimpleRateBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.zYellow)
                
            } else {
                shape
                    .fill(Color.white)
            }
        }
    }
}

struct RateComponent_Previews: PreviewProvider {
    static var previews: some View {
        RateComponent(selectedIndex: .constant(3))
    }
}
