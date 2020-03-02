//
//  ZcashSeedWordPill.swift
//  wallet
//
//  Created by Francisco Gindre on 3/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashSeedWordPill: View {
    
    var number: Int
    var word: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.zDarkGray2)
                
                HStack(alignment: .center, spacing: 4) {
                    
                    Text(String(self.number))
                        .baselineOffset(geometry.size.height/8)
                        .font(.system(size: 10))
                        .foregroundColor(Color.zYellow)
                        
                    
                    Text(self.word)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                        
                   
                }
                .padding(.horizontal, 8)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                
                
            }.overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 0.75)
                    .foregroundColor(Color.zGray)
                
            )
        }
    }
}

struct ZcashSeedWordPill_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack {
                ZcashSeedWordPill(number: 1, word: "1234")
                    .frame(width: 100, height: 30, alignment: .leading)
                ZcashSeedWordPill(number: 23, word: "12345")
                    .frame(width: 100, height: 30)
                ZcashSeedWordPill(number: 23, word: "123456")
                    .frame(width: 100, height: 30)
                ZcashSeedWordPill(number: 23, word: "1234567")
                .frame(width: 100, height: 30)
                ZcashSeedWordPill(number: 23, word: "12345678")
                .frame(width: 100, height: 30)
            }
            
        }
    }
}
