//
//  ZcasMemoTextField.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI



struct ZcashMemoTextField: View {
    @Binding var text: String
    @Binding var includesReplyTo: Bool
    @State var textHeight: CGFloat = 48
    @Binding var charLimit: Int
    
    var activeColor = Color.zAmberGradient2
    var inactiveColor = Color.zGray2
    var isHighlighted: Bool {
        text.count > 0 || includesReplyTo
    }
    
    var paragraphStyle: NSParagraphStyle {
        let p = NSMutableParagraphStyle()
        p.firstLineHeadIndent = 50
        return p
    }
    
    var body: some View {
        ZStack{
            ZStack(alignment: .bottom){
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("\("label_memo".localized()):")
                            .foregroundColor(isHighlighted ? inactiveColor : .white)
                        Text("label_add_memo")
                            .foregroundColor(inactiveColor)
                            .opacity(self.text.isEmpty ? 1 : 0)
                            .allowsHitTesting(false)
                        
                        Spacer()
                        }

                
                    Spacer()
                        .frame(height: textHeight)
                     
                }
                .edgesIgnoringSafeArea(.all)
                VStack(alignment: .trailing, spacing: 0) {
                    TextView(placeholder: "",
                             text: $text,
                             minHeight: self.textHeight,
                             limit: $charLimit,
                             calculatedHeight: $textHeight, typingAttributes: [ NSAttributedString.Key.paragraphStyle : paragraphStyle])
                        .foregroundColor(.white)
                        .frame(height: textHeight)
                        .padding(4)
                        .multilineTextAlignment(.leading)
                    .overlay(
                        Baseline().stroke(isHighlighted ? activeColor : inactiveColor , lineWidth: 2)
                        )

                    HStack {
                        Text(String(format:NSLocalizedString("label_charactercount",comment:""), "\($text.wrappedValue.count)/\(charLimit)"))
                        .font(.footnote)
                        .foregroundColor(inactiveColor)
                        
                        Spacer()
                        Toggle(isOn: $includesReplyTo) {
                            Text("label_replyto")
                        }
                    .toggleStyle(SquareToggleStyle(isHighlighted: $includesReplyTo))
                    }
                    .padding(4)
                }
                
                }
            .padding(0)
        }
       
    }
}

struct ZcashMemoTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center) {
                ZcashMemoTextField(text: .constant(""),
                                   includesReplyTo: .constant(false), charLimit: .constant(512)
                                  )
                    
                    .padding([.leading, .trailing], 24)
            }
        }
    }
}
