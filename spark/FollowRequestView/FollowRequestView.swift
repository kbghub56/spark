//
//  FollowRequestView.swift
//  spark
//
//  Created by Kabir Borle on 2/22/24.
//

//import SwiftUI
//import MapKit
//
//struct FollowRequestView: View {
//    @EnvironmentObject var userManager: UserManager
//    @State private var followRequests: [FollowRequest] = []
//
//    private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//
//    var body: some View {
//        ZStack {
//            Map(coordinateRegion: .constant(region), interactionModes: [])
//                .edgesIgnoringSafeArea(.all)
//                .environment(\.colorScheme, .dark)
//                .disabled(true)  // Disable interaction with the map
//
//            VStack {
//                Text("New Friends?")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.black)
//                    .padding(.top, 50)
//
//                ForEach(followRequests) { request in
//                    HStack {
//                        Text("Request from \(request.fromUserID)")  // Consider fetching the user's name or username
//                            .font(.system(size: 22, weight: .bold))
//                            .padding()
//
//                        Spacer()
//
//                        Button("Accept") {
//                            userManager.handleFollowRequest(request.id, from: request.fromUserID, to: request.toUserID, approved: true)
//                        }
//                        .foregroundColor(.white)
//                        .font(.system(size: 22, weight: .bold))
//                        .padding()
//                        .background(Color.green)
//                        .cornerRadius(10)
//
//                        Button("Reject") {
//                            userManager.handleFollowRequest(request.id, from: request.fromUserID, to: request.toUserID, approved: false)
//                        }
//                        .foregroundColor(.white)
//                        .font(.system(size: 22, weight: .bold))
//                        .padding()
//                        .background(Color.red)
//                        .cornerRadius(10)
//                    }
//                    .frame(width: 350)
//                    .background(Color.white)
//                    .cornerRadius(50)
//                    .padding(.bottom, 10)
//                }
//            }
//            .padding()
//        }
//        .onAppear {
//            userManager.getCurrentUser { user in
//                guard let user = user else { return }
//                userManager.fetchFollowRequests(forUserID: user.uniqueUserID) { requests in
//                    self.followRequests = requests
//                }
//            }
//        }
//    }
//}
