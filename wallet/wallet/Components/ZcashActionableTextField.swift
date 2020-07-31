//
//  ZcashActionableTextField.swift
//  wallet
//
//  Created by Francisco Gindre on 7/27/20.
//  Copyright © 2020 Electric Coin Company
//

import SwiftUI
struct ZcashActionableTextField: View {
    
    var title: String
    var placeholder: String = ""
    var accessoryIcon: Image?
    var action: (() -> Void)?
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType
    var autocorrect = false
    var autocapitalize = false
    var subtitleView: AnyView
    var onCommit: () -> Void
    var onEditingChanged: (Bool) -> Void
    var inactiveColor: Color = .zGray2
    var activeColor: Color = .zAmberGradient2
    
    @Binding var text: String
    
    
    
    var accessoryView: AnyView {
        if let img = accessoryIcon, let action = action {
            return AnyView(
                Button(action: {
                    action()
                }) {
                    img.resizable()
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var isActive: Bool {
        text.count > 0
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text(title)
                    .foregroundColor(isActive ? .zLightGray : .white)
                
                TextField(placeholder,
                          text: $text,
                          onEditingChanged: self.onEditingChanged,
                          onCommit: self.onCommit)
                
                    .accentColor(.white)
                    .foregroundColor(Color.white)
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
                    .autocapitalization(autocapitalize ? .none : .sentences)
                    .disableAutocorrection(!autocorrect)
                    
                accessoryView
                    .frame(width: 25, height: 25)
                    .padding(.bottom,4)
            }.overlay(
                Baseline().stroke(isActive ? activeColor : inactiveColor ,lineWidth: 2)
            )
            .font(.body)
                
            subtitleView
        }
        
    }
    
    init(title: String,
         subtitleView: AnyView? = nil,
         contentType: UITextContentType? = nil,
         keyboardType: UIKeyboardType  = .default,
         binding: Binding<String>,
         action: (() -> Void)? = nil,
         accessoryIcon: Image? = nil,
         onEditingChanged: @escaping (Bool) -> Void,
         onCommit: @escaping () -> Void) {
        
        self.title = title
        self.accessoryIcon = accessoryIcon
        self.action = action
        if let subtitle = subtitleView {
            self.subtitleView = AnyView(subtitle)
        } else {
            self.subtitleView = AnyView(EmptyView())
        }
        self.contentType = contentType
        self.keyboardType = keyboardType
        self._text = binding
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
    }
    
}

struct ZcashActionableTextField_Previews: PreviewProvider {
    
    @State static var text: String = "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
    static var previews: some View {
        ZStack {
            ZcashBackground()
            ZcashTextField(title: "To:".localized(),
                           subtitleView: AnyView(
                            Text("Enter Shielded Address".localized())
                                .foregroundColor(.zLightGray)
                                .font(.footnote)
                            ),
                           binding: $text,
                           action: {},
                           accessoryIcon: Image("QRCodeIcon")
                                                .renderingMode(.original),
                           onEditingChanged: { editing in },
                           onCommit: {}
                
            )
            .padding()
            
        }
    }
}
