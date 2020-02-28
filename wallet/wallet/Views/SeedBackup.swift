//
//  SeedBackup.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct SeedBackup: View {
    let buttonPadding: CGFloat = 40
    let buttonHeight: CGFloat = 58
    
    @State var proceedsToHome = false
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    
    var seed: String {
        do {
            return try SeedManager.default.exportPhrase()
        } catch {
            return "there was an error retrieving your seed: \(error)"
        }
    }
    
    var birthday: String {
        do {
            return  String(try SeedManager.default.exportBirthday())
        } catch {
            return "There was an error retrieving your wallet birthday: \(error)"
        }
    }
    var copyText: String {
        """
        Seed:
        \(seed)
        
        Wallet Birthday:
        \(birthday)
        """
    }
    
    
    var body: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                Text("Your Backup Seed")
                    .foregroundColor(.white)
                    .font(.title)
                
                Text(seed)
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                Spacer()
                Text("Your Wallet Birthday")
                    .foregroundColor(.white)
                    .font(.title)
                    .opacity(0.8)
                
                
                Text(birthday)
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .opacity(0.8)

                Spacer()
                Button(action: {
                    UIPasteboard.general.string = self.copyText
                }) {
                    Text("Copy to clipboard")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .opacity(0.4)
                }
                if proceedsToHome {
                    NavigationLink(destination:  Home(amount: 0, verifiedBalance: appEnvironment.initializer.getBalance().asHumanReadableZecBalance()).environmentObject(appEnvironment)) {
                        ZcashButton(color: Color.black, fill: Color.zYellow, text: "I'm all set!")
                            .frame(height: buttonHeight)
                    }
                    .padding([.leading, .trailing], buttonPadding)
                }
                Spacer()
            }
        }.navigationBarTitle("",displayMode: .inline)
        .navigationBarHidden(false)
        
    }
}

struct SeedBackup_Previews: PreviewProvider {
    static var previews: some View {
        SeedBackup().environmentObject( ZECCWalletEnvironment.shared)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
