//
//  SyncingButton.swift
//  lottie-test
//
//  Created by Francisco Gindre on 1/30/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI
import Lottie
import Combine
struct SyncingButton: View {
    
    class SyncingViewModel: ObservableObject {
        @Published var frameProgress: Float = 0
        var lastFrameProgress: Float = 0
        var progress: Float = 0
        var isSyncing = false
        var dispose = [AnyCancellable]()
        let startFrame: Float = 80
        let endFrame: Float = 101
        init(progressSubject: CurrentValueSubject<Float,Never>) {
            progressSubject.receive(on: DispatchQueue.main)
                
                .sink(receiveCompletion: { _ in
                    self.lastFrameProgress = 0
                    self.isSyncing = false
                }) { (value) in
                    let frame = (self.startFrame + (value * self.endFrame))
                    
                    self.progress = value
                    self.lastFrameProgress = self.frameProgress
                    self.frameProgress = frame
                    self.isSyncing = true
            }.store(in: &dispose)
        }
    }
    var lottieView = LottieAnimation(filename: "lottie_button_loading_new")
    @ObservedObject var viewModel: SyncingViewModel
    init(progressSubject: CurrentValueSubject<Float,Never>) {
        self.viewModel = SyncingViewModel(progressSubject: progressSubject)
    }
    var body: some View {
        ZStack {
            lottieView.onReceive(viewModel.$frameProgress, perform: { (_) in
                self.lottieView.play(from:  AnimationFrameTime(self.viewModel.lastFrameProgress), to: AnimationFrameTime(self.viewModel.frameProgress))
            })
            Text(String(format: NSLocalizedString("balance_syncing", comment: ""),"\(Int($viewModel.progress.wrappedValue*100))"))
                .foregroundColor(.white)
                .opacity(viewModel.progress > 0 && viewModel.progress <= 1 ? 1.0 : 0.0)
        }
    }
}
