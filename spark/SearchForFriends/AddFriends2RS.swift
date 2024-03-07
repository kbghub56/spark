//
//  AddFriends2RS.swift
//  spark
//
//  Created by Kabir Borle on 2/29/24.
//

import SwiftUI
struct AddFrTwo: View {
    var foundUser: User?
    var userManager: UserManager
    @State private var errorMessage: String?
    // Gesture state to detect swipe
    @GestureState private var swipeGesture = false
    var body: some View {
        ZStack {
            Text("Send")
                .font(.system(size: 44, weight: .bold)) // Default SwiftUI font in bold
                .foregroundColor(.white) // Text color changed to white for dark mode
                .offset(x: 0, y: -330)
            
            Text("a friend request")
                .font(.system(size: 44, weight: .bold)) // Default SwiftUI font in bold
                .foregroundColor(.white) // Text color changed to white for dark mode
                .offset(x: 0, y: -170)
            
            Text("Keep in mind your friends can see what you're up to - this is for that group chat and those friends.")
                .font(.system(size: 26)) // Default SwiftUI font, not bold here as per original
                .foregroundColor(.white) // Text color changed to white for dark mode
                .multilineTextAlignment(.center)
                .padding(50)
                .offset(x: 0, y: 50)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 307, height: 71)
                .background(Color.white) // Adjusted for dark mode visibility
                .cornerRadius(100)
                .offset(x: 0, y: -250)
            
            // Text view for displaying the user's email
            Text(foundUser?.email ?? "user email not found") // Use the foundUser's email here
                .foregroundColor(.black) // Text color
                .frame(width: 297, height: 61) // Slightly smaller than the rectangle to fit inside
                .background(Color.white) // Match the rectangle's background if needed
                .cornerRadius(90) // Slightly less than the rectangle's cornerRadius to fit nicely inside
                .offset(x: 0, y: -250) // Match the rectangle's offset

            
            // "Done" (Accept) Button
            Button(action: {
                followFoundUser() // Define the action for the "Done" (Accept) button here
            }) {
                ZStack {
                    Rectangle()
                        .frame(width: 307, height: 120)
                        .cornerRadius(100)
                        .foregroundColor(.white) // Button color changed to white for dark mode
                    
                    Text("Send")
                        .font(.system(size: 36, weight: .bold)) // Default SwiftUI font in bold
                        .foregroundColor(.black) // Text color inside the button kept black for contrast
                }
            }
            .offset(x: 0, y: 320)
            
            // X out Button
            Button(action: {
                print("X Button tapped") // Action for button tap
            }) {
                ZStack {
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white) // Button color changed to white for dark mode
                        .offset(y: 10)
                    
                    Text("X")
                        .font(.system(size: 16, weight: .bold)) // Default SwiftUI font in bold
                        .foregroundColor(.black) // Text color inside the button kept black for contrast
                        .offset(y: 10)
                }
            }
            .offset(x: -150, y: -400) // Adjust position as needed
            
            // Detecting swipe gesture
            .gesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .updating($swipeGesture) { value, state, transaction in
                        if value.startLocation.x < value.location.x {
                            state = true
                            print("Swipe detected - triggering X button action")
                        }
                    }
            )
        }
        .frame(width: 430, height: 932)
        .background(.black) // Background color set to black for dark mode
    }
    
    func followFoundUser() {
        guard let foundUser = foundUser else { return }

        userManager.getCurrentUser { currentUser in
            guard let currentUser = currentUser else {
                errorMessage = "Failed to get current user details"
                return
            }

            userManager.sendFollowRequest(from: currentUser.uniqueUserID, to: foundUser.uniqueUserID)
        }
    }
}



