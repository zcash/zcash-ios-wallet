//
//  SeedBackup.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct SeedBackup: View {
    var words: [String]
    
    let wordsPerRow = 4
    
    var body: some View {
        ZStack {
            Background()
            VStack(alignment: .leading, spacing: 24) {
                Text("Your Seed Backup")
                    .font(.title)
                    .foregroundColor(Color.zYellow)
               
                
                    VStack(alignment: .center, spacing: 8) {
                        
                        ForEach(words.chunked(into: wordsPerRow), id: \.self) { row in
                            
                            HStack(alignment: .firstTextBaseline, spacing: 20) {
                                ForEach(row, id:\.self) { word in
                                    Text(word)
                                        .foregroundColor(Color.zYellow)
                                        .font(.headline)
                                        .lineLimit(1)
                                        .padding(8)
                                        .background(Color.zGray)
                                    
                                }
                            }
                        }
                    }
                
            }
        }
        .navigationBarTitle("Your Seed Backup")
    }
}

struct SeedBackup_Previews: PreviewProvider {
    static var previews: some View {
        
        return SeedBackup(words: FakeProvider().seedWords(limit: 16))
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
