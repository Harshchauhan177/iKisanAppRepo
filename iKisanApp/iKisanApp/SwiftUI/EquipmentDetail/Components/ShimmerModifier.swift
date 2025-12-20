//
//  ShimmerModifier.swift
//  iKisanApp
//
//  Shimmer effect for loading states following HIG
//

import SwiftUI

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5
    var bounce: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.3),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: geometry.size.width * phase)
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: duration)
                                .repeatForever(autoreverses: bounce)
                        ) {
                            phase = 1
                        }
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer(duration: Double = 1.5, bounce: Bool = false) -> some View {
        modifier(Shimmer(duration: duration, bounce: bounce))
    }
}
