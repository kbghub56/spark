//
//  landingPageDemo.swift
//  spark
//
//  Created by Kabir Borle on 4/17/24.
//

import SwiftUI

struct LandingPage2: View {
    @State private var isExpanded = false
    @State private var currentTextIndex = 0
    let texts = [
        "checking what your friends are up to...",
        "finding the hottest parties near you...",
        "making plans for tonight..."
    ]

    var body: some View {
        ZStack () {
            VStack(spacing: 30){
                Text("⚡️")
                    .font(.system(size: 88))
                    .foregroundColor(.white)

                Text("Spark")
                    .font(.system(size: 55, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }.padding(.top, 140)
                ZStack {
                    Circle()
                        .frame(width: isExpanded ? 12 : 24, height: isExpanded ? 12 : 24)
                        .foregroundColor(.white)
                        .offset(x: isExpanded ? 0 : -24, y: isExpanded ? -135 : -159)
                        .scaleEffect(0.65)
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: isExpanded ? 12 : 24, height: isExpanded ? 12 : 24)
                        .offset(x: isExpanded ? 0 : 24, y: isExpanded ? -135 : -159)
                        .scaleEffect(0.65)
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: isExpanded ? 12 : 24, height: isExpanded ? 12 : 24)
                        .offset(x: isExpanded ? 0 : -24, y: isExpanded ? -135 : -109)
                        .scaleEffect(0.65)
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: isExpanded ? 12 : 24, height: isExpanded ? 12 : 24)
                        .offset(x: isExpanded ? 0 : 24, y: isExpanded ? -135 : -109)
                        .scaleEffect(0.65)
                }
                .frame(width: isExpanded ? 50 : 100, height: isExpanded ? 50 : 100)
                .background(Color.black)
                .offset(x: 0, y: 278)
                
                Text(texts[currentTextIndex])
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .offset(x: 0, y: 275)
            }
            .frame(width: 430, height: 932)
            .background(Color.black)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    isExpanded = true
                }
                
                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                    withAnimation {
                        currentTextIndex = (currentTextIndex + 1) % texts.count
                    }
                }
            }
        }
}

struct LandingPage2_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage2()
    }
}
