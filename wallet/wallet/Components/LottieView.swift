//
//  LottieView.swift
//  lottie-test
//
//  Created by Francisco Gindre on 1/30/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI
import Lottie

extension LottieView {
    func currentProgress(_ progress: Float) {
        self.animationView.currentProgress = AnimationProgressTime(progress)
    }
    
    func currentFrame(_ frame: Float) {
        self.animationView.play(toFrame: AnimationFrameTime(frame))
    }
    
    func play(from: AnimationFrameTime, to: AnimationFrameTime) {
        animationView.play(fromFrame: from, toFrame: to, loopMode: .none, completion: nil)
    }
}

struct LottieView: UIViewRepresentable {
    let animationView = AnimationView()
    var filename: String
   
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        let animation = Lottie.Animation.named(filename)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: animationView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: animationView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: animationView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: animationView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        
        return view
    }
    
    
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
       
    }
    
}
