//
//  locationQuestion.swift
//  spark
//
//  Created by Kabir Borle on 4/4/24.
//

import SwiftUI
import CoreLocation

struct LocationQuestion: View {
    @State private var yOffset: CGFloat = 600 // Initial offset for the sliding elements
    @State private var isOverlayActive: Bool = false // Controls the overlay's tap activation
    @State private var isAllowButtonPressed: Bool = false // State for the Allow button press animation
    @EnvironmentObject var authViewModel: AuthViewModel
    let locationManager = CLLocationManager() // Location manager instance

    var body: some View {
        ZStack {
            // Transparent overlay that becomes tappable after the rectangle moves up
            if isOverlayActive {
                Color.black.opacity(0.001) // Almost fully transparent
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            yOffset = 600 // Reverse the slide-up animation
                            isOverlayActive = false // Deactivate the overlay
                        }
                    }
            }

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isAllowButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isAllowButtonPressed = false
                        requestLocationPermission()
                        authViewModel.navigateToSnapAvatar1 = true
                        print("SET TO TRUE")
                    }
                }
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 375, height: 58)
                        .background(Color(red: 0, green: 0.57, blue: 0.80))
                        .cornerRadius(100)
                        .scaleEffect(isAllowButtonPressed ? 0.95 : 1.0)
                    
                    Text("Allow")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(isAllowButtonPressed ? 0.95 : 1.0)
                }
            }
            .offset(x: 0, y: 250)
            .animation(.easeInOut(duration: 0.2), value: isAllowButtonPressed)

            Text("So, are you from around here?")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .offset(x: 0, y: -300)

            Text("Set your location to see your friends and events nearby. Don't miss out on what's happening otherwise.")
                .font(.system(size: 17))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .offset(x: 0, y: -128.50)

            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .offset(x: 0, y: 120)

            Image("gps_4120467") // Ensure this image is in your assets
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .offset(x: 0, y: 120)

            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 400, height: 554)
                .background(Color.white)
                .cornerRadius(60)
                .offset(x: 0, y: yOffset)
                .animation(.easeOut(duration: 0.5), value: yOffset)
                .onTapGesture {
                    withAnimation {
                        yOffset = 100 // Slide up
                        isOverlayActive = true // Activate the overlay after the animation
                    }
                }

            Text("How is my location used?")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .offset(x: 0, y: yOffset - 235)
                .animation(.easeOut(duration: 0.5), value: yOffset)

            Text("Don't worry —— ")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .offset(x: 0, y: yOffset - 40)
                .animation(.easeOut(duration: 0.5), value: yOffset)

            Text("Your location helps us show friends and events nearby. Your location is only shown to approved friends, never publicly shared.")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(40)
                .offset(x: 0, y: yOffset + 20)
                .animation(.easeOut(duration: 0.5), value: yOffset)
        }
        .frame(width: 430, height: 932)
        .background(Color.black)
    }

    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

struct LocationQuestion_Previews: PreviewProvider {
    static var previews: some View {
        LocationQuestion()
    }
}
