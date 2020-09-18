//
//  WalletDetails.swift
//  wallet
//
//  Created by Francisco Gindre on 1/21/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
class WalletDetailsViewModel: ObservableObject {
    // look at before changing https://stackoverflow.com/questions/60956270/swiftui-view-not-updating-based-on-observedobject
    @Published var items = [DetailModel]()
    var showError = false
    var balance: Double = 0
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        ZECCWalletEnvironment.shared.synchronizer.walletDetailsBuffer
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (d) in
                self?.items = d
            })
            .store(in: &cancellables)
        
        ZECCWalletEnvironment.shared.synchronizer.balance
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (b) in
                self?.balance = b
            })
            .store(in: &cancellables)
        
    }
    deinit {
        cancellables.forEach { (c) in
            c.cancel()
        }
    }
    
    var balanceStatus: BalanceStatus {
        let status = ZECCWalletEnvironment.shared.balanceStatus
        switch status {
        case .available(_):
            return .available(showCaption: false)
        default:
            return status
        }
    }
    
    var zAddress: String {
        ZECCWalletEnvironment.shared.initializer.getAddress() ?? ""
    }
}

struct WalletDetails: View {
    @EnvironmentObject var viewModel: WalletDetailsViewModel
    @State var selectedId: String? = nil
    @Binding var isActive: Bool
    var zAddress: String {
        viewModel.zAddress
    }
    
    var status: BalanceStatus {
        viewModel.balanceStatus
    }
    
    var body: some View {
        
        ZStack {
            ZcashBackground()
            VStack(alignment: .center) {
                ZcashNavigationBar(
                    leadingItem: {
                        Button(action: {
                            self.isActive.toggle()
                        }) {
                            Image("Back")
                                .renderingMode(.original)
                        }
                    },
                   headerItem: {
                        BalanceDetail(
                            availableZec: ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value,
                            status: status)
                    },
                   trailingItem: { EmptyView() }
                )
                    .padding(.horizontal, 10)

                List {
                    WalletDetailsHeader(zAddress: zAddress)
                        .listRowBackground(Color.zDarkGray2)
                        .frame(height: 100)
                        .padding([.trailing], 24)
                    ForEach(self.viewModel.items, id: \.id) { row in
                        NavigationLink(destination: LazyView(TransactionDetails(detail: row, selectedId: self.$selectedId)), tag: row.id, selection: self.$selectedId) {
                            DetailCard(model: row, backgroundColor: .zDarkGray2)
                        }
                        .isDetailLink(false)
                        .listRowBackground(Color.zDarkGray2)
                        .frame(height: 69)
                        .padding(.horizontal, 16)
                        .cornerRadius(0)
                        .border(Color.zGray, width: 1)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                .listStyle(PlainListStyle())
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.zGray, lineWidth: 1.0)
                )
                .padding()
                
                Spacer()
                
            }
        }
        .onAppear() {
            
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().backgroundColor = UIColor.clear
            tracker.track(.screen(screen: .history), properties: [:])

        }
        .onDisappear() {
            UITableView.appearance().separatorStyle = .singleLine

        }
        .edgesIgnoringSafeArea([.bottom])
        .navigationBarHidden(true)
        .alert(isPresented: self.$viewModel.showError) {
            Alert(title: Text("Error".localized()),
                  message: Text("an error ocurred".localized()),
                  dismissButton: .default(Text("button_close".localized())))
        }
    }
}

struct WalletDetails_Previews: PreviewProvider {
    static var previews: some View {
        return WalletDetails(isActive: .constant(true)).environmentObject(ZECCWalletEnvironment.shared)
    }
}

class MockWalletDetailViewModel: WalletDetailsViewModel {
    
    override init() {
        super.init()
        
    }
    
}

extension DetailModel {
    static var mockDetails: [DetailModel] {
        var items =  [DetailModel]()
       
            items.append(contentsOf:
                [
                    
                    DetailModel(
                        id: "bb031",
                        zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        zecAmount: -12.345,
                        status: .paid(success: true),
                        subtitle: "1 of 10 confirmations"
                        
                    ),
                    
                    
                    DetailModel(
                        id: "bb032",
                        zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        zecAmount: 2.0,
                        status: .received,
                        subtitle: "Received 11/16/19 4:12pm"
                        
                    ),
                    
                    
                    DetailModel(
                        id: "bb033",
                        zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        zecAmount: 2.0,
                        status: .paid(success: false),
                        subtitle: "Received 11/16/19 4:12pm"
                    )
                    
                ]
            )
        
        return items
    }
}
