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
    private var cancellables = Set<AnyCancellable>()
    func load() {
        SceneDelegate.shared.environment?.synchronizer.walletDetails
        .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                
                switch completion {
                case .failure(let error):
                    print("error: \(error)")
                default:
                    break
                }
            }, receiveValue: { self.items = $0 })
        .store(in: &self.cancellables)
    }
    
}

struct WalletDetails: View {
    @State var balance: Double
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @ObservedObject var viewModel = WalletDetailsViewModel()
    
    var zAddress: String
    var status: BalanceStatus {
        appEnvironment.balanceStatus
    }
    
    var body: some View {
        
        ZStack {
            ZcashBackground()
            VStack(alignment: .center) {
                
                List {
                        WalletDetailsHeader(zAddress: zAddress)
                            .listRowBackground(Color.zDarkGray2)
                            .frame(height: 100)
                            .padding([.trailing], 24)
                    ForEach(self.viewModel.items, id: \.id) { row in
                            DetailCard(model: row, backgroundColor: Color.zDarkGray2)
                                .listRowBackground(Color.zDarkGray2)
                                .frame(height: 69)
                                .padding(.horizontal, 16)
                                .cornerRadius(0)
                                .border(Color.zGray, width: 1)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
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
            
            guard self.viewModel.items.isEmpty else {
                return
            }
            
            self.viewModel.load()
            
        }
        .onDisappear() {
            UITableView.appearance().separatorStyle = .singleLine
            UITableView.appearance().backgroundColor = UIColor.white
        }
        .edgesIgnoringSafeArea([.bottom])
        .navigationBarItems(trailing:
            HStack {
                BalanceDetail(availableZec: balance, status: status)
                Spacer().frame(width: 80)
            }
        )
    }
}

struct WalletDetails_Previews: PreviewProvider {
    static var previews: some View {
        
       
        return WalletDetails(
            balance: 1.2345,
            viewModel: MockWalletDetailViewModel(),
            zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        ).environmentObject(try! ZECCWalletEnvironment())
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
