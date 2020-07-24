//
//  AddressFragment.swift
//  wallet
//
//  Created by Francisco Gindre on 7/24/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct AddressFragment: View {
    
    var number: Int
    var word: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                HStack(alignment: .center, spacing: 4) {
                    
                    Text(String(self.number))
                        .baselineOffset(geometry.size.height/8)
                        .font(.system(size: 10))
                        .foregroundColor(Color.zYellow)
                        .frame(minWidth: geometry.size.width*0.18, alignment: .trailing)
                        
                    
                    Text(self.word)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        
                        
                   
                }
                .padding(.trailing, 4)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                
                
            }
        }
    }
}

struct AddressFragment_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack {
                AddressFragment(number: 1, word: "1234")
                    .frame(width: 100, height: 30, alignment: .leading)
                AddressFragment(number: 23, word: "12345")
                    .frame(width: 100, height: 30)
                AddressFragment(number: 23, word: "123456")
                    .frame(width: 100, height: 30)
                AddressFragment(number: 23, word: "1234567")
                .frame(width: 100, height: 30)
                AddressFragment(number: 23, word: "12345678")
                .frame(width: 100, height: 30)
            }
            
        }
    }
}
