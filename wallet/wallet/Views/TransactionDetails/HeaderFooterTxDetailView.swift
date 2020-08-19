//
//  HeaderFooterTxDetailView.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 8/17/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct HeaderFooterTxDetailView : View {
    var caption: Text
    var mainText: Text
    var highlighted: Bool = false
    var outline: Color
    var accessory: AnyView
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                caption
                mainText
            }

            Spacer()
            accessory
        }
        .padding()
        .background(Color.zGray)
        .overlay(Topline()
        .stroke(outline, lineWidth: 1)
            
        )
    }
}
import Foundation
struct HeaderFooterFactory {
    
    
    static func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "undefined"
        
    }
    
    static func outline(success: Bool, shielded: Bool) -> Color  {
        guard success else {
            return Color.red
        }
        
        if shielded {
            return Color.zYellow
        }
        
        return Color.zYellow
    }
    
    static func failedHeaderWithValue(_ value: Double,
                                      shielded: Bool,
                                      formatValue: (Double) -> String = Self.formatValue) -> HeaderFooterTxDetailView {
        HeaderFooterTxDetailView(
            caption: Text("You Failed to send")
                .foregroundColor(.white)
                .font(.footnote)
                .bold(),
            mainText: Text("$\(formatValue(value))")
                .font(Font.zoboto(size: 36))
                .foregroundColor(.zLightGray),
            outline: Color.red,
            accessory: Image("outgoing_failed").eraseToAnyView()
        )
    }
    static func failedFooterWithValue(_ value: Double,
                                      shielded: Bool,
                                      formatValue: (Double) -> String = Self.formatValue) -> HeaderFooterTxDetailView {
        HeaderFooterTxDetailView(
                           caption: Text("Total Spent")
                               .foregroundColor(.white)
                               .font(.footnote)
                               .bold(),
                           mainText: Text("$\(formatValue(value))")
                               .font(Font.zoboto(size: 36))
                               .foregroundColor(.zLightGray),
                           outline: outline(success: false, shielded: shielded),
                           accessory: EmptyView().eraseToAnyView()
                       )
    }
    static func successHeaderWithValue(_ value: Double,
                                       shielded: Bool,
                                       formatValue: (Double) -> String = Self.formatValue) -> HeaderFooterTxDetailView {
        HeaderFooterTxDetailView(
                           caption: Text("You Sent")
                               .foregroundColor(.zYellow)
                               .font(.footnote),
                           mainText: Text("$\(formatValue(value))")
                               .font(Font.zoboto(size: 36))
                               .foregroundColor(.white),
                           outline: outline(success: true, shielded: shielded),
                           accessory: Image("outgoing_confirmed").eraseToAnyView()
                       )
    }
    
    static func successFooterWithValue(_ value: Double,
                                       shielded: Bool,
                                       formatValue: (Double) -> String = Self.formatValue) -> HeaderFooterTxDetailView {
        HeaderFooterTxDetailView(
                          caption: Text("Total Spent")
                              .foregroundColor(.zYellow)
                              .font(.footnote),
                          mainText: Text("$\(formatValue(value))")
                              .font(Font.zoboto(size: 36))
                              .foregroundColor(.white),
                          outline: .zYellow,
                          accessory: EmptyView().eraseToAnyView()
                      )
    }
}

struct HeaderFooterTxDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack {
            ZcashBackground()
            VStack(spacing: 40){
                HeaderFooterFactory.failedHeaderWithValue(4.32, shielded: true)
                
                HeaderFooterFactory.failedFooterWithValue(0, shielded: true)
                
                HeaderFooterFactory.successHeaderWithValue(4.32, shielded: true)
                
                HeaderFooterFactory.successFooterWithValue(4.32, shielded: true)
                
              
            }
            
        }
    }
}
