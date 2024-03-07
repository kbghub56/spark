//
//  FriendRequestRS.swift
//  spark
//
//  Created by Kabir Borle on 3/4/24.
//

import SwiftUI

struct FriendRequest: View {
    @EnvironmentObject var userManager: UserManager
    @State private var followRequests: [FollowRequest] = []

    var body: some View {
        VStack {
            // Iterate over followRequests to create UI for each
            ForEach(followRequests) { request in
                followRequestView(request: request)
            }
        }
        .onAppear {
            userManager.fetchFollowRequests(forUserID: userManager.currentUser?.uniqueUserID ?? "") { requests in
                self.followRequests = requests
            }
        }
    }

    @ViewBuilder
    private func followRequestView(request: FollowRequest) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.white)
                .frame(width: 350, height: 150)

            VStack {
                Text("Request from \(request.fromUserID)") // Consider fetching the user's name
                    .font(.system(size: 22, weight: .bold))

                HStack(spacing: 20) {
                    Button("Accept") {
                        userManager.handleFollowRequest(request.id, from: request.fromUserID, to: request.toUserID, approved: true)
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold))
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)

                    Button("Deny") {
                        userManager.handleFollowRequest(request.id, from: request.fromUserID, to: request.toUserID, approved: false)
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold))
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
        }
        .padding(.bottom, 20)
    }
}

struct FriendRequest_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequest().environmentObject(UserManager())
    }
}
