//
//  FeedbackDialog.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 4/8/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ScreenOverlay<ForegroundContent: View>: ViewModifier {
    @Binding var isOverlayShown: Bool
    var foregroundContent: ForegroundContent
    
    init(isOverlayShown: Binding<Bool>, foregroundContent: () -> ForegroundContent) {
        self._isOverlayShown = isOverlayShown
        self.foregroundContent = foregroundContent()
    }
    func body(content: Content) -> some View {
        if isOverlayShown {
            ZStack {
                content
                ZcashBackground()
                    .opacity(0.6)
                    .onTapGesture {
                        self.isOverlayShown = false
                    }
                ZStack {
                    foregroundContent
                }
                .padding(.all, 0)
            }
            .transition(.opacity)
        } else {
            content
        }
    }
}

extension View {
    func zOverlay<ForegroundContent: View>(isOverlayShown: Binding<Bool>,
                                           foregroundContent: () -> ForegroundContent) -> some View {
        self.modifier(ScreenOverlay(isOverlayShown: isOverlayShown, foregroundContent: foregroundContent))
    }
}

struct FeedbackDialog: View {
    enum Step {
        case initial
        case feedBackTapped(rating: Int)
    }
    enum Feedback {
        case score(rating: Int)
        case requestAdditional(rating: Int)
    }
    
    @State var step: Step = .initial
    @Binding var rating: Int?
    
    var feedBackResult: (Feedback) -> ()
    
    @ViewBuilder func buildStep() -> some View {
        if case Step.initial = step {
            VStack(alignment: .center, spacing: 20) {
                Text("Rate your Experience!")
                    .foregroundColor(.black)
                    .font(.title)
                VStack(spacing: 4) {
                    RateComponent(selectedIndex: $rating) { index in
                        self.step = .feedBackTapped(rating: index)
                    }
                    
                    HStack {
                        Text("Very Bad")
                            .font(.caption)
                            .foregroundColor(.zDarkGray1)
                        Spacer()
                        Text("Very Good")
                            .font(.caption)
                            .foregroundColor(.zDarkGray1)
                    }
                }
                .padding(0)
            }
        } else {
            VStack(alignment: .center, spacing: 20) {
                Text("Want to share details?")
                    .foregroundColor(.black)
                    .font(.title)
                Button(action: {
                    if case .feedBackTapped(let score) = step {
                        feedBackResult(.requestAdditional(rating: score))
                    }
                }, label: {
                    Text("Yes!")
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: .white)))
                })
                .frame(height: 48)
                
                Button(action: {
                    if case .feedBackTapped(let score) = step {
                        feedBackResult(.score(rating: score))
                    }
                }, label: {
                    Text("Nope")
                        .foregroundColor(.black)
                })
                .frame(height: 48)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.white
                .opacity(0.8)
            buildStep()
                .padding()
        }
        .cornerRadius(20, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        .animation(.easeInOut)
    }
}

