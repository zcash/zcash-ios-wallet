//
//  ZcashSeedPhraseGrid.swift
//  wallet
//
//  Created by Francisco Gindre on 3/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashSeedPhraseGrid: View {
    let columns = 3
    var wordGrid: [[String]]
    init(words: [String]) {
        self.wordGrid = words.slice(maxSliceCount: columns)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ForEach(wordGrid.indices, id: \.self) { i in
                HStack(alignment: .center, spacing: 6) {
                    ForEach(self.wordGrid[i].indices, id: \.self) { j in
                        ZcashSeedWordPill(number: (i * self.columns) + j + 1, word: self.wordGrid[i][j])
                        .frame(width: 100, height: 30)
                    }
                }
            }
        }
    }
}

struct ZcashSeedPhraseGrid_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            ZcashSeedPhraseGrid(words: try! MnemonicSeedProvider.default.asWords(mnemonic: "kitchen renew wide common vague fold vacuum tilt amazing pear square gossip jewel month tree shock scan alpha just spot fluid toilet view dinner"))
        }
    }
}

extension Array {
    
    func slice(maxSliceCount: Int) -> [[Element]] {
        precondition(maxSliceCount > 0)
        var grid = [[Element]]()
        for i in 0 ..< self.count/maxSliceCount {
            var row = [Element]()
            for j in (i * maxSliceCount) ..< Swift.min(i * maxSliceCount + maxSliceCount, self.count) {
                row.append(self[j])
            }
            grid.append(row)
        }
        return grid
    }
}
