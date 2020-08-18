//
//  TransactionDetails.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 8/18/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct TransactionDetails: View {
    var detail: DetailModel
    @State var explorerAlert = false
    
    var exploreButton: some View {
        Button(action: {
            
        }) {
            HStack {
                Spacer()
                Text("Explore")
                    .foregroundColor(.zGray2)
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.zGray2)
                Spacer()
            }
            .padding()
            .frame(height: 48)
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
                .foregroundColor(.zGray2)
        )
    }
    var body: some View {

        ZStack {
            ZcashBackground()
            VStack(spacing: 30) {
                VStack {
                    DateAndHeight(date: detail.date, formatterBlock: formatDateDetail, height: detail.minedHeight)
                    HeaderFooterFactory.header(for: detail)
                    SubwayPathBuilder.buildSubway(detail: detail, expandMemo: .constant(false))
                    HeaderFooterFactory.footer(for: detail)
                    
                }
                
                if detail.success {
                    Spacer()
                    exploreButton
                    
                }
                
            }
            .padding()
            .alert(isPresented: self.$explorerAlert) {
                Alert(title: Text("You are exiting your wallet"),
                      message: Text("While usually an acceptable risk, you will possibly exposing your behavior and interest in this transaction by going online. OH  NOES! What will you do?"),
                      primaryButton: .cancel(Text("NEVERMIND")),
                      secondaryButton: .default(Text("SEE TX ONLINE"), action: {
                        /// Todo: open url
                      }))
            }
        }
        .navigationBarTitle(Text("Transaction Detail"), displayMode: .inline)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
            
        
    }
}

struct SubwayPathBuilder {
    static func buildSubway(detail: DetailModel, expandMemo: Binding<Bool>) -> some View {
        var views = [AnyView]()
        
        
        views.append(
            Text("+0.0001 network fee")
                .font(.body)
                .foregroundColor(.gray)
                .eraseToAnyView()
        )
        
        views.append(
            Text("from your shielded wallet")
                .font(.body)
                .foregroundColor(.gray)
                .eraseToAnyView()
        )
        
        if let memo = detail.memo {
            views.append(
                WithAMemoView(expanded: expandMemo, memo: detail.memo ?? "")
                    .eraseToAnyView()
            )
            
            if memo.includesReplyTo {
                views.append(
                    Text("includes reply-to")
                        .font(.body)
                        .foregroundColor(.gray)
                        .eraseToAnyView()
                )
            }
        }
        
        if let toAddr = detail.zAddress {
            views.append(
                (Text("to ")
                    .font(.body)
                    .foregroundColor(.white) +
                    Text(toAddr)
                        .font(.body)
                        .foregroundColor(.gray))
                    .eraseToAnyView()
            )
        }
        
        if detail.success {
            views.append(
                Text("confirmed")
                    .font(.body)
                    .foregroundColor(detail.shielded ? .zYellow : .zTransparentBlue)
                    .eraseToAnyView()
            )
        } else {
            views.append(
                Text("failed!")
                    .font(.body)
                    .foregroundColor(.red)
                    .eraseToAnyView()
            )
        }
        return DetailListing(details: views)
    }
}
extension DetailModel {
    var success: Bool {
        switch self.status {
        case .paid(let success):
            return success
        default:
            return true
        }
    }
}

extension String {
    var includesReplyTo: Bool {
        false
    }
}

extension HeaderFooterFactory {
    static func header(for detail: DetailModel) -> some View {
        detail.success ?
            Self.successHeaderWithValue(detail.zecAmount, shielded: detail.shielded) :
            Self.failedHeaderWithValue(detail.zecAmount, shielded: detail.shielded)
    }
    
    static func footer(for detail: DetailModel) -> some View {
        detail.success ? Self.successFooterWithValue(detail.zecAmount, shielded: detail.shielded) : self.failedFooterWithValue(detail.zecAmount, shielded: detail.shielded)
    }
}

func formatDateDetail(_ date: Date) -> String {
    "2020-04-14 5:12am"
}

struct TransactionDetails_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            TransactionDetails(detail: DetailModel(id: "fasdfasdf", date: Date(), zecAmount: 4.32, status: .received, subtitle: "fasdfasd"))
        }
    }
}


