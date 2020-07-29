//
//  TextView.swift
//  wallet
//
//  Created by Francisco Gindre on 2/18/20.
//
//
// Credits to https://stackoverflow.com/questions/56471973/how-do-i-create-a-multiline-textfield-in-swiftui

import SwiftUI
import UIKit
struct TextView: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String
    @Binding var limit: Int
    var minHeight: CGFloat
    var typingAttributes: [NSAttributedString.Key: Any]
    @Binding var calculatedHeight: CGFloat
    
    init(placeholder: String,
         text: Binding<String>,
         minHeight: CGFloat,
         limit: Binding<Int>,
         calculatedHeight: Binding<CGFloat>,
         typingAttributes: [NSAttributedString.Key: Any]
          = [:]) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self._limit = limit
        self.typingAttributes = typingAttributes
        self._calculatedHeight = calculatedHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        
        textView.typingAttributes = typingAttributes
        // Decrease priority of content resistance, so content would not push external layout set in SwiftUI
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        textView.font = UIFont.systemFont(ofSize: 16)
        // Set the placeholder
        textView.text = placeholder
        textView.textColor = UIColor.white

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != self.text {
            textView.text = self.text
        }
        context.coordinator.limit = self.limit
        recalculateHeight(view: textView)
    }

    func recalculateHeight(view: UIView) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if minHeight < newSize.height && $calculatedHeight.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                self.$calculatedHeight.wrappedValue = newSize.height // !! must be called asynchronously
            }
        } else if minHeight >= newSize.height && $calculatedHeight.wrappedValue != minHeight {
            DispatchQueue.main.async {
                self.$calculatedHeight.wrappedValue = self.minHeight // !! must be called asynchronously
            }
        }
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView
        var limit: Int
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
            self.limit = uiTextView.limit
        }

        func textViewDidChange(_ textView: UITextView) {
            // This is needed for multistage text input (eg. Chinese, Japanese)
            if textView.markedTextRange == nil {
                parent.text = textView.text ?? String()
                parent.recalculateHeight(view: textView)
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {

        }

        func textViewDidEndEditing(_ textView: UITextView) {

        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let userPressedDelete = text.isEmpty && range.length > 0
            return  textView.text.count + text.count <= limit || userPressedDelete
        }
    }
}

