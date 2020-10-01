//
//  TransactionDetails.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 8/18/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct TransactionDetails: View {
    
    enum Alerts {
        case explorerNotice
        case copiedItem(item: PasteboardItemModel)
    }
    var detail: DetailModel
    @State var expandMemo = false
    
    @State var alertItem: Alerts?
    var exploreButton: some View {
        Button(action: {
            self.alertItem = .explorerNotice
        }) {
            HStack {
                Spacer()
                Text("Explore")
                    .foregroundColor(.white)
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .frame(height: 48)
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
                .foregroundColor(.white)
        )
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 30) {
                VStack {
                    DateAndHeight(date: detail.date,
                                  formatterBlock: formatDateDetail,
                                  height: detail.minedHeight)
                    HeaderFooterFactory.header(for: detail)
                    SubwayPathBuilder.buildSubway(detail: detail, expandMemo: self.$expandMemo)
                        .padding(.leading, 32)
                        .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
                            self.alertItem = .copiedItem(item: p)
                        }
                    HeaderFooterFactory.footer(for: detail)
                    
                }
                
                if detail.isMined {
                    exploreButton
                }
            }
            .padding()
        }
        .padding(.vertical,0)
        .padding(.horizontal, 8)
        .alert(item: self.$alertItem) { item -> Alert in
            switch item {
            case .copiedItem(let p):
                return PasteboardAlertHelper.alert(for: p)
            case .explorerNotice:
                return Alert(title: Text("You are exiting your wallet"),
                             message: Text("While usually an acceptable risk, you will possibly exposing your behavior and interest in this transaction by going online. OH NOES! What will you do?"),
                             primaryButton: .cancel(Text("NEVERMIND")),
                             secondaryButton: .default(Text("SEE TX ONLINE"), action: {
                                
                                guard let url = UrlHandler.blockExplorerURL(for: self.detail.id) else {
                                    return
                                }
                                
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                             }))
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
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
        
        if detail.isOutbound {
            views.append(
                Text("from your shielded wallet")
                    .font(.body)
                    .foregroundColor(.gray)
                    .eraseToAnyView()
            )
        } else {
            views.append(
                Text("to your shielded wallet")
                    .font(.body)
                    .foregroundColor(.gray)
                    .eraseToAnyView()
            )
            
        }
        
        if let memo = detail.memo {
            views.append(
                WithAMemoView(expanded: expandMemo, memo: detail.memo ?? "")
                    .eraseToAnyView()
            )
            
            if memo.includesReplyTo {
                views.append(
                    Button(action: {
                        PasteboardAlertHelper.shared.copyToPasteBoard(value: memo.replyToAddress ?? "", notify: "feedback_addresscopied".localized())
                        tracker.track(.tap(action: .copyAddress), properties: [:])
                    }) {
                        Text("includes reply-to")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .eraseToAnyView()
                )
            }
        }
        
        if let fullAddr = detail.zAddress, let toAddr = fullAddr.shortZaddress {
            views.append(
                
                Button(action:{
                    PasteboardAlertHelper.shared.copyToPasteBoard(value: fullAddr, notify: "feedback_addresscopied".localized())
                }){
                    (Text("to ")
                        .font(.body)
                        .foregroundColor(.white) +
                        Text(toAddr)
                        .font(.body)
                        .foregroundColor(.gray))
                }
                .eraseToAnyView()
            )
        }
        
        if detail.success {
            let latestHeight = ZECCWalletEnvironment.shared.synchronizer.syncBlockHeight.value
            let isConfirmed = detail.isConfirmed(latestHeight: latestHeight)
            views.append(
                Text(detail.makeStatusText(latestHeight: latestHeight))
                    .font(.body)
                    .foregroundColor(isConfirmed ?  detail.shielded ? .zYellow : .zTransparentBlue : .zGray2)
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
    
    func makeStatusText(latestHeight: Int) -> String {
        guard !self.isConfirmed(latestHeight: latestHeight) else {
            return "Confirmed"
        }
        
        guard minedHeight > 0, latestHeight > 0 else {
            return "Pending confirmation"
        }
        
        return "\(abs(latestHeight - minedHeight)) \("of 10 Confirmations".localized())"
    }
    
    func isConfirmed(latestHeight: Int) -> Bool {
        guard self.isMined, latestHeight > 0 else { return false }
        
        return abs(latestHeight - self.minedHeight) >= 10
        
    }
    
    var isMined: Bool {
        self.minedHeight.isMined
    }
    
    var success: Bool {
        switch self.status {
        case .paid(let success):
            return success
        default:
            return true
        }
    }
    
    var isOutbound: Bool {
        switch self.status {
        case .paid:
            return true
        default:
            return false
        }
    }
}

extension String {
    static let memoReplyToString = "Reply-To: "
    
    var includesReplyTo: Bool {
        self.replyToAddress != nil
    }
    
    var removingReplyTo: String {
        guard let keywordRange = self.range(of: Self.memoReplyToString) else {
            return self
        }
        return String(self[self.startIndex ..< self.index(before: keywordRange.lowerBound)])
    }
    
    var replyToAddress: String? {
        guard let keywordRange = self.range(of: Self.memoReplyToString),
              keywordRange.upperBound < self.endIndex else {
            return nil
        }
        
        let addressSlice = self[keywordRange.upperBound ..< self.endIndex]
        
        let afterReplyToString = String(addressSlice)
        
        guard afterReplyToString.isValidShieldedAddress else { return nil }
        
        return afterReplyToString
        
    }
}

fileprivate func formatAmount(_ amount: Double) -> String {
    abs(amount).toZecAmount()
}

extension HeaderFooterFactory {
    static func header(for detail: DetailModel) -> some View {
        detail.success ?
            Self.successHeaderWithValue(detail.zecAmount,
                                        shielded: detail.shielded,
                                        sent: detail.isOutbound,
                                        formatValue: formatAmount) :
            Self.failedHeaderWithValue(detail.zecAmount,
                                       shielded: detail.shielded,
                                       formatValue: formatAmount)
    }
    // adds network fee on successful transactions
    static func footer(for detail: DetailModel) -> some View {
        detail.success ? Self.successFooterWithValue(detail.isOutbound ? detail.zecAmount.addingZcashNetworkFee() : detail.zecAmount,
                                                     shielded: detail.shielded,
                                                     sent: detail.isOutbound,
                                                     formatValue: formatAmount) :
            self.failedFooterWithValue(detail.zecAmount,
                                       shielded: detail.shielded,
                                       formatValue: formatAmount)
    }
}

func formatDateDetail(_ date: Date) -> String {
    date.transactionDetailFormat()
}

struct TransactionDetails_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            TransactionDetails(detail: DetailModel(id: "fasdfasdf", date: Date(), zecAmount: 4.32, status: .received, subtitle: "fasdfasd"))
        }
    }
}


extension TransactionDetails.Alerts: Identifiable {
    var id: Int {
        switch self {
        case .copiedItem(_):
            return 1
        default:
            return 2
        }
    }
}
