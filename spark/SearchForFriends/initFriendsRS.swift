//
//  initFriendsRS.swift
//  spark
//
//  Created by Kabir Borle on 3/4/24.
//

import SwiftUI
struct InitFriends: View {
    @State private var isPressed = false // State to handle button press animation
    @State private var userInput: String = ""
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Let's check on your friends")
                    .font(.system(size: 48, weight: .bold)) // Default system font in bold
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .offset(y: 40)
                
                Text("Your link")
                    .font(.system(size: 24, weight: .bold)) // Default system font in bold
                    .foregroundColor(.white)
                    .offset(x: -120, y: 130)
                
                Text("Your SparkID")
                    .font(.system(size: 24, weight: .bold)) // Default system font in bold
                    .foregroundColor(.white)
                    .offset(x: -95, y: 250)
                
                Text("Add a Spark-ID")
                    .font(.system(size: 24, weight: .bold)) // Default system font in bold
                    .foregroundColor(.white)
                    .offset(x: -85, y: 345)
                
                Text("Keep in mind your friends can see what you're up to - this is for that group chat and those friends.")
                    .font(.system(size: 20)) // Default system font in bold
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal) // Adds horizontal padding to keep the text within the screen
                    .offset(y: -110)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 320, height: 60)
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .cornerRadius(20)
                    .offset(x: 0, y: -60)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 320, height: 60)
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .cornerRadius(20)
                    .offset(x: 0, y: 27)
                
                TextField("              This field is optional", text: $userInput)                    .foregroundColor(.black).padding(20)
                    .frame(width: 320, height: 60)
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .cornerRadius(20)
                    .offset(x: 0, y: 90)
                
                Text("id input field")
                    .font(.system(size: 14, weight: .bold)) // Default system font in bold
                    .foregroundColor(.black)                    .multilineTextAlignment(.center)
                    .offset(x: -85, y: 70)
                
                // Animated Share Button
                Group{
                    Button(action: {
                        self.isPressed.toggle()
                    }) {
                        HStack {
                            Image(systemName: "arrow.turn.up.right")
                                .rotationEffect(.degrees(-45))
                                .font(.title3) // Smaller icon
                            Text("Share")
                                .font(.system(size: 18, weight: .bold)) // Default system font in bold
                        }
                        .foregroundColor(.white)
                        .padding(8) // Smaller padding
                        .background(Color(#colorLiteral(red: 0.537254902, green: 0.8117647059, blue: 0.9411764706, alpha: 1))) // Baby blue background
                        .cornerRadius(8) // Adjusted corner radius
                        .scaleEffect(isPressed ? 1.1 : 1.0) // Scales up when pressed
                        .animation(.easeInOut(duration: 0.2), value: isPressed)
                    }
                    .offset(y: -270)
                    Button(action: {
                        // Action for when the Continue button is pressed
                    }) {
                        HStack(spacing: 0) {
                            Text("Continue")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(EdgeInsets(top: 28, leading: 136, bottom: 72, trailing: 137))
                        .frame(width: 390, height: 120)
                        .background(.white)
                        .cornerRadius(40)
                    }
                    .offset(y: 50)
                }
            }
        }
        .frame(width: 430, height: 932)
        .background(.black)
    }
}
struct InitFriends_Previews: PreviewProvider {
    static var previews: some View {
        InitFriends()
    }
}

