//
//  removeFriendPopup.swift
//  spark
//
//  Created by Kabir Borle on 4/14/24.
//

import SwiftUI

struct RemoveFriendPopup: View {
    var friendID: String
    var friendName: String
    @Binding var showPopup: Bool
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.black)
                .frame(width: 350, height: 350)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.white, lineWidth: 2)
                )
                .overlay(
                    VStack(spacing: 20) {
                        Text("Remove \(friendName)")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("as a friend")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        HStack(spacing: 45) {
                            Button("Accept") {
                                guard let currentUserUniqueID = userManager.currentUser?.uniqueUserID else {
                                    print("Current user unique ID not found")
                                    return
                                }
                                userManager.removeAsFriend(currentUserUniqueID: currentUserUniqueID, friendID: friendID)
                                showPopup = false
                            }
                            .foregroundColor(.black)
                            .font(.system(size: 22, weight: .bold))
                            .padding()
                            .scaleEffect(0.8)
                            .background(Color.white)
                            .cornerRadius(10)
                            
                            Button("Deny") {
                                showPopup = false
                            }
                            .foregroundColor(.white)
                            .scaleEffect(0.8)
                            .font(.system(size: 22, weight: .bold))
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                        }.padding(.bottom, 48)
                    }
                    .padding(.top, 48)
                )
        }
    }
}

