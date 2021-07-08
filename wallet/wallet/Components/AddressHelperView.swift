//
//  AddressHelperView.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 7/30/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI
extension Notification.Name {
    static let addressSelection = Notification.Name(rawValue: "addressSelected")
}
struct AddressHelperView: View {
    
    enum Mode {
        case lastUsed(address: String)
        case clipboard(address: String)
        case both(clipboard: String, lastUsed: String)
    }
    
    enum Selection {
        case clipboardSelection
        case lastUsedSelection
        case none
    }
    @Binding var selection: Selection
    @Environment(\.walletEnvironment) var appEnvironment
    var mode: Mode
    var body: some View {
        viewFor(mode)
            .background(Color.clear)
    }
    
    func onTap(selection: Selection, value: String) {
        if self.selection == selection {
            self.selection = .none
            NotificationCenter.default.post(name: .addressSelection, object: nil, userInfo: ["value": ""])
        } else {
            self.selection = selection
            NotificationCenter.default.post(name: .addressSelection, object: nil, userInfo: ["value": value])
        }
    }
    
    func viewFor(_ mode: Mode) -> some View {
        switch mode {
        case .lastUsed(let address):
            return VStack(spacing: 0) {
                AddressHelperViewSection(title: "LAST USED") {
                    AddrezzHelperViewCell(shieldingAddress: appEnvironment.shieldingAddress, address: address, shielded: isValidZ(address: address),selected: self.selection == Selection.lastUsedSelection)
                }.onTapGesture {
                    self.onTap(selection: Selection.lastUsedSelection, value: address)
                }
            }.eraseToAnyView()
        case .both(let clipboard, let lastUsed):
            return VStack(spacing: 0) {
                AddressHelperViewSection(title: "send_onclipboard".localized()) {
                    AddrezzHelperViewCell(shieldingAddress: appEnvironment.shieldingAddress, address: clipboard, shielded: isValidZ(address: clipboard),selected: self.selection == Selection.clipboardSelection)
                }
                .onTapGesture {
                    self.onTap(selection: Selection.clipboardSelection, value: clipboard)
                }
                AddressHelperViewSection(title: "LAST USED") {
                    AddrezzHelperViewCell(shieldingAddress: appEnvironment.shieldingAddress, address: lastUsed, shielded: isValidZ(address: lastUsed   ),selected: self.selection == Selection.lastUsedSelection)
                }
                .onTapGesture {
                    self.onTap(selection: Selection.lastUsedSelection, value: lastUsed)
                }
            }.eraseToAnyView()
        
        case .clipboard(let address):
           return  VStack(spacing: 0) {
            AddressHelperViewSection(title: "send_onclipboard".localized()) {
                AddrezzHelperViewCell(shieldingAddress: appEnvironment.shieldingAddress, address: address, shielded: isValidZ(address: address),selected: self.selection == Selection.clipboardSelection)
                }
            .onTapGesture {
                self.onTap(selection: Selection.clipboardSelection, value: address)
            }
            }.eraseToAnyView()
        }
    }
    
    func isValidT(address: String) -> Bool {
        DefaultAddressValidator.isValidTransparentAddress(address)
    }
    
    func isValidZ(address: String) -> Bool {
        DefaultAddressValidator.isValidShieldedAddress(address)
    }
}

struct AddressHelperViewSectionHeader:  View {
    var title: String
    var body: some View {
        ZStack {
            Color.zDarkGray1
            HStack(alignment: .center){
                Text(title)
                    .foregroundColor(.zLightGray2)
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 24)
    }
}
struct AddressHelperViewSection<Content: View>: View {
    var title: String
    var content: Content
    
    init(title: String, @ViewBuilder content: () -> (Content)) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            AddressHelperViewSectionHeader(title: title)
            
            content
                .padding(.leading, 16)
        }
    }
}
struct AddrezzHelperViewCell: View {
    var shieldingAddress: String
    var address: String
    var shielded: Bool
    var selected: Bool = false
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if shielded {
                    HStack {
                        Image(selected ? "yellow_shield" : "gray_shield")
                        
                        Text("\(text)")
                            .foregroundColor(selected ? .zYellow : .white)
                            .font(.body)
                    }
                } else {
                    Text("\(text) (+)")
                        .foregroundColor(.white)
                        .font(.body)
                }
                Text(address)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .opacity(selected ? 1 : 0.6)
            }
            Image("yellow_tick")
                .renderingMode(.original)
                .opacity(selected ? 1 : 0)
                .padding(15)
        }
        .padding(.vertical, 16)
    }
    
    var text: String {
        if address == shieldingAddress {
            return "Your Auto Shielding Address"
        } else {
            return "Unknown"
        }
    }
}
struct AddressHelperView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                ZcashBackground()
                
                AddressHelperView(selection: .constant(.none),mode: .both(clipboard: "ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6", lastUsed: "tuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"))
                
            }
        }
    }
}
