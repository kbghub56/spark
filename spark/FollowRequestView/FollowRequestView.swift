//
//  FollowRequestView.swift
//  spark
//
//  Created by Kabir Borle on 2/22/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct FollowRequestView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var followRequests: [FollowRequest] = []

    var body: some View {
        List(followRequests) { request in
            HStack {
                Text("Request from \(request.fromUserID)")  // Ideally, fetch and display the user's name or username
                Spacer()
                Button("Approve") {
                    print("PRESSED 1")
                    userManager.handleFollowRequest(request.id, from: request.fromUserID, to: request.toUserID, approved: true)
                }
                .buttonStyle(PlainButtonStyle())  // Use PlainButtonStyle to ensure the button doesn't interfere with List row tap gestures
                Spacer()
                Button("Reject") {
                    print("PRESSED 2")
                    userManager.handleFollowRequest(request.id, from: request.fromUserID, to: request.toUserID, approved: false)
                }
                .buttonStyle(PlainButtonStyle())  // Use PlainButtonStyle here as well
            }
            .contentShape(Rectangle())  // This makes the entire HStack tappable...
            .onTapGesture {
                // ...but this onTapGesture does nothing, effectively ignoring taps on the HStack itself
            }
        }
        .onAppear {
            userManager.getCurrentUser { user in
                guard let user = user else { return }
                userManager.fetchFollowRequests(forUserID: user.uniqueUserID) { requests in
                    self.followRequests = requests
                }
            }
        }
    }
}
