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
    @State private var foundUser: User?
    @State private var errorMessage: String?
    @State private var isShowingSheet = false
    @EnvironmentObject var userManager: UserManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer() // Pushes the Text to the center
                    Text("Let's check on your friends")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center) // Text itself is center-aligned
                    Spacer() // Ensures the Text stays centered
                }
                .padding(.top, 16) // Add some top padding to position it from the top edge
                
                Text("Keep in mind your friends can see what you're up to - this is for that group chat and those friends.")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading) // Left-aligned
                
                Text("Your link:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)
                
                Text("spark.sampleurl.personxyzpenispe")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading) // Left-aligned
                    .padding(.trailing, 60) // Make room for the button
                
                // ZStack for overlaying the button on the text
                ZStack {
                    Button(action: {
                        self.isPressed.toggle()
                    }) {
                        HStack {
                            Image(systemName: "arrow.turn.up.right")
                                .rotationEffect(.degrees(-45))
                                .font(.title3)
                            Text("Share")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(#colorLiteral(red: 0.537254902, green: 0.8117647059, blue: 0.9411764706, alpha: 1)))
                        .cornerRadius(8)
                        .scaleEffect(isPressed ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isPressed)
                    }
                    .scaleEffect(0.8)
                    .offset(x: 100) // Adjust this value as needed to position the button correctly over the text
                }
                
                Text("Your SparkID:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)
                
                Text(userManager.currentUser?.uniqueUserID ?? "Not Found")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading) // Left-aligned
                
                Text("You can add a SparkID:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)
                
                TextField(" ", text: $userInput)
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .cornerRadius(20)
                    .scaleEffect(0.9)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.leading)
                }
                
                Button(action: {
                    if userInput.isEmpty {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        searchForUser()
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.white)
                        .cornerRadius(40)
                }
                .padding(.top, 50)
                .sheet(isPresented: $isShowingSheet) {
                    AddFrTwo(foundUser: foundUser, userManager: userManager)
                }
                
               
            }
            .padding(.horizontal, 16) // Add additional horizontal padding to each element
        }
        .padding(16) // Padding around the entire content
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
    
    // Search for user based on ID
    func searchForUser() {
        userManager.searchForUser(by: userInput) { result in
            switch result {
            case .success(let user):
                foundUser = user
                errorMessage = nil
                isShowingSheet = true
            case .failure(let error):
                errorMessage = "Not a valid Spark ID. Please retry."//error.localizedDescription
                foundUser = nil
            }
        }
    }
}

struct InitFriends_Previews: PreviewProvider {
    static var previews: some View {
        InitFriends()
    }
}
