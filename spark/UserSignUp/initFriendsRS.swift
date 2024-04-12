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
            VStack(alignment: .leading, spacing: 32.5) {
                HStack {
                    Spacer()
                    Text("Let's check on your friends")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding(.top, 16)
                
                Text("Keep in mind your friends can see what you're up to - this is for that group chat and those friends.")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                
                Text("Your link:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)
                
                HStack {
                    Text("spark.sampleurl.personxyzpenispe")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 60)
                    
                    ZStack {
                        VStack {
                            Button(action: {
                                self.isPressed.toggle()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                Text("Your SparkID:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)
                
                Text(userManager.currentUser?.uniqueUserID ?? "Not Found")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 60)

                Text("Add a SparkID:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)
                
                HStack {
                    TextField("Optional", text: $userInput)
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 21, leading: 16, bottom: 21, trailing: 16))
                        .background(.gray)
                        .cornerRadius(20)
                }
                
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
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(.white)
                        .cornerRadius(40)
                        .padding(.top, 25)
                }
                .padding(.horizontal, 16)
                .sheet(isPresented: $isShowingSheet) {
                                AddFrTwo(foundUser: foundUser, userManager: userManager, isPresented: $isShowingSheet)
                            }
            }
            .padding(16)
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

