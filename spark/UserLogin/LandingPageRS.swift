//
//  LandingPageRS.swift
//  spark
//
//  Created by Kabir Borle on 3/6/24.
//

import SwiftUI
struct LandingPage: View {
    @State private var isExpanded = false
    @State private var currentTextIndex = 0
    let texts = [
        "checking what your friends are up to...",
        "finding the hottest parties near you...",
        "making plans for tonight..."
    ]
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .frame(width: isExpanded ? 12 : 24, height: isExpanded ? 12 : 24)
                    .foregroundColor(.white)
                    .offset(x: isExpanded ? 0 : -24, y: isExpanded ? -135 : -159) // Adjusted Y offset
                Circle()
                    .foregroundColor(.white)
                    .frame(width: isExpanded ? 12 : 24, height: isExpanded ? 12 : 24)
                    .offset(x: isExpanded ? 0 : 24, y: isExpanded ? -135 : -159) // Adjusted Y offset
                Circle()
                    .foregroundColor(.white)
                    .frame(width: isExpanded ? 12 : 24, height: isExpanded ? 12 : 24)
                    .offset(x: isExpanded ? 0 : -24, y: isExpanded ? -135 : -109) // Adjusted Y offset
                Circle()
                    .foregroundColor(.white)
                    .frame(width: isExpanded ? 12 : 24, height: isExpanded ? 12 : 24)
                    .offset(x: isExpanded ? 0 : 24, y: isExpanded ? -135 : -109) // Adjusted Y offset
            }
            .frame(width: isExpanded ? 50 : 100, height: isExpanded ? 50 : 100)
            .background(Color.black)
            .offset(x: 0, y: 268) // Adjusted Y offset
            
            Text("⚡️")
                .font(.system(size: 128)) // Default system font
                .foregroundColor(.white)
                .offset(x: 0, y: -251)
            
            Text("Spark")
                .font(.system(size: 64)) // Default system font
                .foregroundColor(.white)
                .offset(x: 0, y: -135)
            
            Text(texts[currentTextIndex])
                .font(.system(size: 22)) // Default system font
                .foregroundColor(.white)
                .offset(x: 0, y: 325)
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
struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
    }
}

