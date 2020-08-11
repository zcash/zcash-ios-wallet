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
    
    @Published var items: [DetailModel] = []
    var showError = false
    var balance: Double = 0
    private var cancellables = Set<AnyCancellable>()

    init(){
        pollData()
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
    func pollData() {
        ZECCWalletEnvironment.shared.synchronizer.walletDetails
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] (completion) in
                guard let self = self else { return }
                switch completion {
                case .failure(_):
                    self.showError = true
                case .finished:
                    break
                }
            }) { (models) in
                self.items = [DetailModel](models)
        }
            
        .store(in: &cancellables)
        
        ZECCWalletEnvironment.shared.synchronizer.balance
            .receive(on: RunLoop.main)
            .assign(to: \.balance, on: self)
            .store(in: &cancellables)
    }
}

struct WalletDetails: View {
    @EnvironmentObject var viewModel: WalletDetailsViewModel
    @Binding var isActive: Bool
    @State var transactions = [DetailModel]()
    @State var isDetailActive = false
    @State var selectedIndex = -1
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
                            self.isActive = false
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
                    ForEach(0 ..< transactions.count, id: \.self) { index in
                        Button(action: {
                            self.selectedIndex = index
                            self.isDetailActive = true
                        }) {
                        DetailCard(model: self.transactions[index], backgroundColor: Color.zDarkGray2)
                           
                        }
                        
                    } .listRowBackground(Color.zDarkGray2)
                                               .frame(height: 69)
                                               .padding(.horizontal, 16)
                                               .cornerRadius(0)
                                               .border(Color.zGray, width: 1)
                                               .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.zGray, lineWidth: 1.0)
                )
                .padding()
                    .onReceive(viewModel.$items) { (txs) in
                        self.transactions = txs
                }
                
                Spacer()
                
            }
        }
        .onAppear() {
            
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().backgroundColor = UIColor.clear
            
        }
        .onDisappear() {
            UITableView.appearance().separatorStyle = .singleLine
        }
        .edgesIgnoringSafeArea([.bottom])
        .sheet(isPresented:$isDetailActive) {
            LazyView(
                NavigationView {
                    TransactionDetails(model: self.transactions[self.selectedIndex], isActive: self.$isDetailActive)
                }
            )
        }
        .alert(isPresented: self.$viewModel.showError) {
                Alert(title: Text("Error".localized()), message: Text("an error ocurred".localized()), dismissButton: .default(Text("OK".localized())))
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
        self.items = DetailModel.mockDetails
    }
    
}

extension DetailModel {
    static var mockDetails: [DetailModel] {
        var items =  [DetailModel]()
        for _ in 0 ... 5 {
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
        }
        return items
    }
}
