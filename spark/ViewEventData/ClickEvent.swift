//
//  ClickEvent.swift
//  spark
//
//  Created by Kabir Borle on 3/28/24.
//

import SwiftUI
struct ClickEvent: View {
    @State private var isLiked = false
    @State private var isShared = false
    @State private var isBookmarked = false
    var body: some View {
        ZStack {
            ZStack {
                Text("Event Name")
                    .font(.system(size: 40, weight: .heavy)) // Default SwiftUI font in bold
                    .foregroundColor(.white) // Text color changed to white
                    .offset(x: 0, y: -305)
                
                Text("invite status")
                    .font(.system(size: 24, weight: .heavy)) // Default SwiftUI font in bold
                    .foregroundColor(.white) // Text color changed to white
                    .offset(x: -60, y: -250)
                
                Text("description")
                    .font(.system(size: 24, weight: .heavy)) // Default SwiftUI font in bold
                    .foregroundColor(.white) // Text color changed to white
                    .offset(x: -65, y: -220)
                
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 170, height: 170) // Circle will use the width for diameter
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .offset(x: 0, y: -50)
                Text("if >0 friends liked display profiles of mutuals")
                    .font(.system(size: 20, weight: .heavy)) // Default SwiftUI font in bold
                    .foregroundColor(.white) // Text color changed to white
                    .padding() // Added padding around the text
                    .offset(x: 0, y: 200)
                
                // Social Buttons Container
                HStack(spacing: 30) {
                    // Like Button with adjusted offset
                    VStack {
                        Button(action: {
                            withAnimation {
                                self.isLiked.toggle()
                            }
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 24 * 2.5))
                                .scaleEffect(isLiked ? 1.5 : 1)
                                .foregroundColor(isLiked ? .red : .white) // Button color changed to white
                        }
                    }
                    .offset(x: 0,y: -200) // Adjusted offset for Like Button
                    // Share Button with adjusted offset
                    VStack {
                        Button(action: {
                            withAnimation {
                                self.isShared.toggle()
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24*2.5))
                                .scaleEffect(isShared ? 1.5 : 1)
                                .foregroundColor(.white) // Button color changed to white
                        }
                    }
                    .offset(x: 0, y: -210) // Adjusted offset for Share Button
                }
                .offset(x: 0, y: 320) // Adjust the vertical position of the buttons container
                
                // "Done" button inside a light yellow box, scaled up
                Button(action: {
                    print("Done button tapped") // Define the action for your button here
                }) {
                    Text("Done")
                        .foregroundColor(.black) // Set the text color to white
                        .font(.title.weight(.bold)) // Adjusted for dynamic scaling
                        .padding() // Adjust padding if needed to accommodate the larger size
                        .background(Color.white)
                        .cornerRadius(10)
                        .scaleEffect(1.25) // Scale up the entire Text view including the background
                }
                .offset(x: 0, y: 300) // You might need to adjust this offset based on the new size
            }
            .frame(width: 300, height: 700)
            .background(.black)
            .cornerRadius(50)
        }
        .frame(width: 430, height: 932)
        .background(.white)
    }
}
struct ClickEvent_Previews: PreviewProvider {
    static var previews: some View {
        ClickEvent()
    }
}




