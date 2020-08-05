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

protocol LottieAnimatable {
    
    func currentProgress(_ progress: Float)
    func currentFrame(_ frame: Float)
    func play(from: AnimationFrameTime, to: AnimationFrameTime)
    func play(loop: Bool)
}

extension LottieAnimation: LottieAnimatable {
    func currentProgress(_ progress: Float) {
        self.animationView.currentProgress = AnimationProgressTime(progress)
    }
    
    func currentFrame(_ frame: Float) {
        self.animationView.play(toFrame: AnimationFrameTime(frame))
    }
    
    func play(from: AnimationFrameTime, to: AnimationFrameTime) {
        animationView.play(fromFrame: from, toFrame: to, loopMode: .none, completion: nil)
    }
    
    func play(loop: Bool = false) {
        if loop {
            animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop, completion: nil)
        } else {
            animationView.play()
        }
    }
}

struct LottieAnimation: UIViewRepresentable {
    let animationView = AnimationView()
    var filename: String
   
    func makeUIView(context: UIViewRepresentableContext<LottieAnimation>) -> UIView {
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
    
    
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieAnimation>) {
       
    }
    
}


struct PlayLottie: ViewModifier {
    var loop: Bool = false
    func body(content: Content) -> some View {
        play(content: content)
    }
    
    private func play(content: Content) -> some View {
        guard let lottie = content as? LottieAnimatable else {
            return content
        }
        lottie.play(loop: loop)
        return content
    }
    
}

extension View where Self == LottieAnimation {
    func playAnimation() -> some View {
        self.modifier(PlayLottie())
    }
}
