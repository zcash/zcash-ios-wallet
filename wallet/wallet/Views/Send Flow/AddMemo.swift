//
//  AddMemo.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct AddMemo: View {
    var body: some View {
        
        ZStack {
            Background()
            ZcashMemoTextView()
            
            Spacer()
        }
        
    }
}

struct AddMemo_Previews: PreviewProvider {
    static var previews: some View {
        AddMemo()
    }
}
