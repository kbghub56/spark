//
//  blockFriendPopup.swift
//  spark
//
//  Created by Kabir Borle on 4/18/24.
//

import Foundation
import SwiftUI

struct BlockFriendPopup: View {
    var friendID: String
    var friendName: String
    @Binding var showPopup: Bool
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var authViewModel: AuthViewModel

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
                        Text("Block \(friendName)")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("and remove as a friend")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Spacer()

                        HStack(spacing: 45) {
                            Button("Block") {
                                guard let currentUserID = authViewModel.currentUserID else {
                                    print("Current user ID not found")
                                    return
                                }
                                userManager.blockUser(currentUserID: currentUserID, userToBlockID: friendID)
                                showPopup = false
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .bold))
                            .padding()
                            .scaleEffect(0.8)
                            .background(Color.red)
                            .cornerRadius(10)

                            Button("Cancel") {
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
