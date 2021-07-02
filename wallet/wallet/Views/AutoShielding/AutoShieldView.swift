//
//  AutoShield.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 6/30/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
final class AutoShieldingViewModel: ObservableObject {
    enum State {
        case shielding
        case failed(error: Error)
        case success
    }
    
    @Published var state: State = .shielding
    
    var shielder: AutoShielder
    var cancellables = [AnyCancellable]()
    init(shielder: AutoShielder) {
        self.shielder = shielder
    }
    func shield() {
        do {
            ShieldFlow.endFlow()
            let shieldFlow = try ShieldFlow.startWithShilderOrFail(self.shielder)
            
                shieldFlow.status
                .map { status -> State in
                    switch status {
                    case .ended:
                        return State.success
                    case .notStarted,
                         .shielding:
                        return State.shielding
                    }
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.state = State.failed(error: error)
                    }
                } receiveValue: { [weak self] state in
                    self?.state = state
                }
                .store(in: &cancellables)
            
            shieldFlow.shield()
            
        } catch {
            self.state = .failed(error: error)
        }
    }
}

struct AutoShieldView: View {
    
    @EnvironmentObject var viewModel: AutoShieldingViewModel
    @Binding var isShown: Bool
    var body: some View {
        ZStack {
            ZcashBackground()
            viewFor(viewModel.state)
                .padding()
        }
        .onAppear() {
            viewModel.shield()
        }
        .onDisappear() {
            ModelFlyWeight.shared.dispose(flyweight: viewModel)
        }
    }
    
    @ViewBuilder func viewFor(_ state: AutoShieldingViewModel.State) -> some View {
        switch state {
        case .shielding:
            Self.shieldingScreen()
        case .success:
            success()
        case .failed(let error):
            failureScreen(error: error)
        }
    }
    
    @ViewBuilder func failureScreen(error: Error) -> some View {
        VStack(alignment: .center, spacing: 40) {
            Image("sadZebra")
            Text("Autoshielding failed with this error:")
                .foregroundColor(.zLightGray2)
                .font(.headline)
            Text(error.localizedDescription)
                .foregroundColor(.zLightGray2)
                .font(.body)
            
            Text("Autoshielding will be attempted again later.")
                .foregroundColor(.zLightGray2)
                .font(.body)
            
            dismissButton(text: Text("Dismiss")
                            .foregroundColor(.black))
        }
    }
    
    @ViewBuilder func success() -> some View {
        VStack(alignment: .center, spacing: 40) {
            VStack(alignment: .center, spacing: 30) {
            Image("profile_yellowzebra")
                .animation(.easeIn)
            Text("Your transparent funds are now being shielded!")
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            }
            LottieAnimation(isPlaying: true,
                            filename: "lottie_success",
                            animationType: .playOnce)
                .frame(height: 100)
            
            
            dismissButton(text: Text("Dismiss")
                                    .foregroundColor(.black))
            
        }
    }
    
    @ViewBuilder func dismissButton(text: Text) -> some View {
        Button(action: {
            self.isShown = false
        }, label: {
            text.zcashButtonBackground(
                shape: .roundedCorners(fillStyle: .solid(color: .zYellow)))
                .frame(height: 48, alignment: .center)
        })
    }
    
    @ViewBuilder static func shieldingScreen() -> some View {
        VStack {
            Text("Shielding")
                .foregroundColor(.white)
                .font(.title)
            Text("Do not close this screen")
                .foregroundColor(.white)
                .font(.caption)
                .opacity(0.6)
            LottieAnimation(isPlaying: true,
                            filename: "lottie_shield",
                            animationType: .circularLoop)
                
        }
        .padding([.horizontal, .vertical], 24)
    }
}


struct AutoShield_Previews: PreviewProvider {
    static var previews: some View {
        AutoShieldView(isShown: .constant(true))
    }
}
