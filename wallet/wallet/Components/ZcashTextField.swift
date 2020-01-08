//
//  ZcashTextField.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashTextField: View {
    
    var title: String
    var subtitle: String?
    
    var accessoryIcon: Image?
    var action: (() -> Void)?
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType
    
    @Binding var text: String
    
    struct Baseline: Shape {
        func path(in rect: CGRect) -> Path {
            Path {
                path  in
                path.move(
                    to: CGPoint(
                        x: rect.origin.x,
                        y: rect.maxY
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: rect.maxX,
                        y:  rect.maxY
                    )
                )
            }
        }
        
    }
    
    var accessoryView: AnyView {
        if let img = accessoryIcon, let action = action {
            return AnyView(
                Button(action: {
                    action()
                }) {
                    img
                    .resizable()
                        
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var subtitleView: AnyView {
        if let sub = subtitle {
            return AnyView(
                Text(sub)
                    .foregroundColor(.zLightGray)
                    .font(.footnote)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.white)
        
                HStack {
                    TextField("", text: $text)
                        .textContentType(contentType)
                        .keyboardType(keyboardType)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding([.top])
                    accessoryView
                    .frame(width: 25, height: 25)
                    }.overlay(
                        Baseline()                        .stroke(Color.zAmberGradient2,lineWidth: 2)
                        )
                        
            
            .font(.footnote)
            subtitleView
        }
    }
    
    init(title: String, subtitle: String?, contentType: UITextContentType? = nil, keyboardType: UIKeyboardType  = .default, binding: Binding<String>, action: (() -> Void)? = nil, accessoryIcon: Image? = nil) {
        self.title = title
        self.accessoryIcon = accessoryIcon
        self.action = action
        self.subtitle = subtitle
        self.contentType = contentType
        self.keyboardType = keyboardType
        self._text = binding
    }
    
}

struct ZcashTextField_Previews: PreviewProvider {
    
    @State static var text: String = "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
    static var previews: some View {
        ZStack {
            ZcashBackground()
            ZcashTextField(title: "To", subtitle: "Enter Shielded Address", binding: $text, action: {}, accessoryIcon:Image("QRCodeIcon")
            .renderingMode(.original)
                   )
            .padding()
            
        }
    }
}
