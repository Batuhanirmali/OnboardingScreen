//
//  LottieView.swift
//  OnboardingScreen
//
//  Created by Talha Batuhan Irmalı on 9.11.2024.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {

    var name: String!
    let loopMode: LottieLoopMode
    @Binding var isPlaying: Bool

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()

        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        if let animationView = uiView.subviews.first(where: { $0 is LottieAnimationView }) as? LottieAnimationView {
            isPlaying ? animationView.play() : animationView.pause()
        }
    }
    
}
