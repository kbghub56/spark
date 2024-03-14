//
//  MainPageRS.swift
//  spark
//
//  Created by Kabir Borle on 2/27/24.
//

import SwiftUI
import MapKit
import Combine

struct HomeMapView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var mapState = MapState()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userManager: UserManager
    @State private var showingFollowRequestPopup = false
    
    @State private var isForYouSelected = true
    @State private var showMenu = false
    @State private var showExpandedBlackScreen = false
    @State private var selectedTab = 0
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var isSwitchOn = true
    @State private var showingLocationOffView = false // State to control the presentation of the WhenLocationOff view
    @State private var showingAddFriendView = false
    @State private var currentRequestIndex = 0
    @State private var followRequests: [FollowRequest] = []
    
    private func handleFollowRequestVisibility() {
        if followRequests.isEmpty {
            showingFollowRequestPopup = false
            currentRequestIndex = 0  // Reset the index for any future follow requests
        }
    }



    var body: some View {
        ZStack {
            MapViewRepresentable(eventsViewModel: eventsViewModel, locationManager: locationManager, mapState: mapState, authViewModel: authViewModel)
                .edgesIgnoringSafeArea(.all)

            toggleSection
            circleButton

            if showExpandedBlackScreen {
                ZStack{
                    expandedBlackScreenView
//                    RankedEventsListView()
//                                    .environmentObject(eventsViewModel)
                }
            } else {
                // Default view when not expanded
                RoundedRectangle(cornerRadius: 50).fill(Color.black).frame(height: UIScreen.main.bounds.height / 8).offset(y: 400).onTapGesture {
                    withAnimation {
                        showExpandedBlackScreen = true
                    }
                }
            }

            if showMenu {
                SideMenu(showMenu: $showMenu, isSwitchOn: $isSwitchOn, showingLocationOffView: $showingLocationOffView)
                    .transition(.move(edge: .trailing))
                    .environmentObject(userManager)
                    .environmentObject(authViewModel)
            }
            
            // Usage in HomeMapView
            if showingFollowRequestPopup && !followRequests.isEmpty {
                let request = followRequests[currentRequestIndex]
                FollowRequestPopup(
                    request: followRequests[currentRequestIndex],
                    onAccept: {
                        userManager.handleFollowRequest(request.id, from: request.fromUserID, to: request.toUserID, approved: true)
                        moveToNextOrDismiss()
                    },
                    onReject: {
                        userManager.handleFollowRequest(request.id, from: request.fromUserID, to: request.toUserID, approved: false)
                        moveToNextOrDismiss()
                    }
                )
            }


        }
        .onTapGesture {
            withAnimation {
                if showExpandedBlackScreen {
                    showExpandedBlackScreen = false
                }
                if showMenu {
                    showMenu = false
                }
            }
        }
        .onAppear {
                    // This might be redundant if you're already setting the user in UserManager's init
                    userManager.getCurrentUser { _ in }
                }
                .onReceive(userManager.$currentUser) { user in
                    if let uniqueUserID = user?.uniqueUserID {
                        userManager.fetchFollowRequests(forUserID: uniqueUserID) { requests in
                            followRequests = requests
                            print("FR: \(followRequests)")
                            showingFollowRequestPopup = !requests.isEmpty
                        }
                        
                    }
                }
        .onChange(of: currentRequestIndex) { _ in
            if followRequests.isEmpty {
                showingFollowRequestPopup = false
            }
            handleFollowRequestVisibility()
        }

        
    }
    
    private var isFollowRequestAvailable: Bool {
        currentRequestIndex < followRequests.count
    }
    
    // A new function in HomeMapView to encapsulate moving to the next request or dismissing the popup
    private func moveToNextOrDismiss() {
        if currentRequestIndex < followRequests.count - 1 {
            // Move to the next request
            DispatchQueue.main.async {
                currentRequestIndex += 1
            }
        } else {
            // No more requests, dismiss the popup
            DispatchQueue.main.async {
                showingFollowRequestPopup = false
                currentRequestIndex = 0 // Reset for the next time requests are shown
            }
        }
    }

    var toggleSection: some View {
        ZStack {
            Rectangle().foregroundColor(.clear).frame(width: 100, height: 50).background(Color.white.opacity(0.6)).cornerRadius(50).offset(x: -125, y: -380)
            Text("All").font(.system(size: 13).bold()).foregroundColor(!isForYouSelected ? .white : .gray).offset(x: -155, y: -335)
            Text("For You").font(.system(size: 13).bold()).foregroundColor(isForYouSelected ? .white : .gray).offset(x: -100, y: -335)
            Button(action: {
                withAnimation {
                    isForYouSelected.toggle()
                    eventsViewModel.filterEvents(forFriendsAndMutuals: isForYouSelected) // Filter events based on toggle state
                }
            }) {
                Circle().fill(Color.black).frame(width: 45, height: 45)
            }.offset(x: isForYouSelected ? -130 - 17.5 : -160 + 57.5, y: -375 - 5)
        }
    }

    var circleButton: some View {
        Button(action: {
            withAnimation {
                showMenu = true
            }
        }) {
            Circle().fill(Color.white).frame(width: 75, height: 75)
        }.offset(x: 133.50, y: -378.50)
    }
    var expandedBlackScreenView: some View {
        VStack {
            HStack(spacing: 20) {
                Text("Friends").font(.system(size: 22, weight: selectedTab == 0 ? .bold : .regular))
                    .foregroundColor(selectedTab == 0 ? .white : .gray).padding()
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 0
                        }
                    }
                Spacer()
                Text("Events").font(.system(size: 22, weight: selectedTab == 1 ? .bold : .regular))
                    .foregroundColor(selectedTab == 1 ? .white : .gray).padding()
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 1
                        }
                    }
            }.padding(.horizontal, 60)

            // This will show the RankedEventsListView when the Events tab is selected
            if selectedTab == 1 {
                RankedEventsListView()
                    .environmentObject(eventsViewModel) // Make sure to pass the necessary environment objects
                    .padding(.horizontal) // Add padding if necessary
                    .background(Color.black.opacity(0.7)) // Semi-transparent black background
                    .cornerRadius(10)
                    .padding(.top) // Add padding at the top if necessary
            }

            // The tab view is here for user interaction with the tabs
            TabView(selection: $selectedTab) {
                FriendsView().tag(0)
                EventsView().tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 3 / 4)
        .background(Color.black)
        .cornerRadius(50)
        .transition(.move(edge: .bottom))
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width < 0 {
                    withAnimation {
                        selectedTab = 1
                    }
                } else if value.translation.width > 0 {
                    withAnimation {
                        selectedTab = 0
                    }
                }
            }
        )
        .onTapGesture { }
    }

  
}
struct FriendsView: View {
    @State private var showingAddFriendView = false // State to control sheet presentation
    @EnvironmentObject var userManager: UserManager
    var body: some View {
        VStack {
            Spacer()
            Button(action: {showingAddFriendView = true}) {
                HStack {
                    Image(systemName: "plus").font(.title)
                    Text("Add Friends").font(.system(size: 22, weight: .bold))
                }.foregroundColor(.black).padding().background(Color.white).cornerRadius(10)
            }.padding(.bottom, 20)
            .sheet(isPresented: $showingAddFriendView) { // Present SearchView as a sheet
                    AddFriends()
                    .environmentObject(userManager) // Pass userManager to SearchView
            }
    }
    }
}
struct EventsView: View {
    @State private var showingEventInputView = false
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                showingEventInputView = true
            }) {
                HStack {
                    Image(systemName: "plus").font(.title)
                    Text("Add Events").font(.system(size: 22, weight: .bold))
                }.foregroundColor(.black).padding().background(Color.white).cornerRadius(10)
            }.padding(.bottom, 20)
            .sheet(isPresented: $showingEventInputView) {
                AddEvents()
            }
        }
    }
}
struct SideMenu: View {
    @Binding var showMenu: Bool
    @Binding var isSwitchOn: Bool
    @Binding var showingLocationOffView: Bool
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.frame(width: UIScreen.main.bounds.width * 3 / 4, height: UIScreen.main.bounds.height).cornerRadius(35).offset(y: -12.5).overlay(
                VStack(alignment: .leading) {
                   // Text(authViewModel.sessionTrigger.uuidString).hidden()
                    Circle().fill(Color.white.opacity(0.5)).frame(width: 100, height: 100).padding(.top, 20).offset(y:0)
                    Group{
                        // Display the current user's username, with a default value if it's nil
                        Group {
                                if let username = userManager.currentUser?.userName {
                                    Text(username).font(.system(size: 28).bold()).foregroundColor(.white)
                                } else {
                                    Text("Unknown User").font(.system(size: 28).bold()).foregroundColor(.white)
                                }
                            }
                            .offset(x: 120, y: -120)
                            .padding(.top, 10)

                        Text("near this location").font(.system(size: 20).bold()).foregroundColor(.white).offset(x: 120, y:-120).padding(.top, 5)
                        Text("Location:").font(.system(size: 24).bold()).foregroundColor(.white).offset(y: -45)
                    }
                    VStack {
                        Rectangle().foregroundColor(.clear).frame(width: 100, height: 50).background(Color.white.opacity(0.6)).cornerRadius(50).offset(x: 150, y: -125)
                        HStack{
                            Text("On").font(.system(size: 13).bold()).foregroundColor(isSwitchOn ? .white : .gray).offset(x: -6)
                            Text("Off").font(.system(size: 13).bold()).foregroundColor(isSwitchOn ? .gray : .white).offset(x: 6)
                        }.offset(x:150, y: -125)
                    }.padding(.top, 20)
                    Button(action: {
                        withAnimation {
                            isSwitchOn.toggle()
                            if !isSwitchOn {
                                showingLocationOffView = true // Show WhenLocationOff view when the toggle is switched off
                            }
                        }
                    }) {
                        Circle().fill(Color.white).frame(width: 45, height: 45)
                    }.offset(x: isSwitchOn ? -25 : 25).offset(x:175, y: -200)
                    Button("Change") {}.foregroundColor(.black).padding().background(Color.white).cornerRadius(50).padding(.top, 10).scaleEffect(0.8).offset(x: 2.5, y: -325)
                    Button("Sign Out") {authViewModel.logOut()}.font(.system(size: 24).bold()).foregroundColor(.black).padding().background(Color.white).cornerRadius(50).padding(.top, 10).scaleEffect(1).offset(x: 75, y: 210).zIndex(1)
                    
//                    Button(action: {
//                        print("SIGNED OUT CLICKED")
//                                    authViewModel.logOut() // Call logOut function from AuthViewModel
//                    }) {
//                        Text("Sign Out").font(.system(size: 24).bold()).foregroundColor(.black).padding().background(Color.white).cornerRadius(50).padding(.top, 10).scaleEffect(1).offset(x: 75, y: 210).zIndex(1)
//                    }
                    
                    Text("Your 📷 Collages:").font(.system(size: 28).bold()).foregroundColor(.white).padding(.top, 20).offset(x: 25, y: -280)
                    HStack {
                        Image("PNG image 1").resizable().scaledToFit().frame(width: 100, height: 100).cornerRadius(15).blur(radius: 1.5)
                        Image("PNG image 2").resizable().scaledToFit().frame(width: 100, height: 100).cornerRadius(15).blur(radius: 1.5)
                    }.offset(x: 27.5, y: -270).padding(.top, 20)
                    HStack {
                        Image("PNG image 3").resizable().scaledToFit().frame(width: 100, height: 100).cornerRadius(15).blur(radius: 1.5)
                        Image("PNG image").resizable().scaledToFit().frame(width: 100, height: 100).cornerRadius(15).blur(radius: 1.5)
                    }.offset(x: 27.5, y: -270).padding(.top, 10).overlay(
                        VStack {
                            Image(systemName: "lock.fill").font(.largeTitle).foregroundColor(.white)
                            Text("coming soon ...").font(.title).foregroundColor(.white)
                        }.offset(x: 27.5, y: -325)
                    )
                    //Spacer()
                }.padding(), alignment: .topLeading
            )
            GeometryReader { geometry in
                Color.clear.contentShape(Rectangle()).onTapGesture {
                    withAnimation {
                        showMenu = false
                    }
                }.frame(width: geometry.size.width / 4, height: geometry.size.height)
            }
        }
        .sheet(isPresented: $showingLocationOffView) {
                    WhenLocationOff() // Present the WhenLocationOff view when showingLocationOffView is true
                }
    }
}

struct FollowRequestPopup: View {
    @EnvironmentObject var userManager: UserManager
    var request: FollowRequest
    var onAccept: () -> Void // Closure called when accept is tapped
    var onReject: () -> Void // Closure called when reject is tapped

    var body: some View {
        VStack {
            Text("Follow Request")
                .font(.headline)
                .foregroundColor(.black)

            Text("Request from \(request.fromUserID)")
                .padding()
                .foregroundColor(.black)

            HStack {
                Button("Accept") {
                    onAccept() // Call the accept closure provided by the parent view
                }
                .buttonStyle(FollowRequestButtonStyle(backgroundColor: .black))

                Button("Reject") {
                    onReject() // Call the reject closure provided by the parent view
                }
                .buttonStyle(FollowRequestButtonStyle(backgroundColor: .black))
            }
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}



struct FollowRequestButtonStyle: ButtonStyle {
    var backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct HomeMapView_Preview: PreviewProvider {
    static var previews: some View {
        HomeMapView()
    }
}

struct RankedEventsListView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) { // Adjust the spacing between items
                ForEach(eventsViewModel.sortedEventsByLikesFromFriends, id: \.id) { event in
                    HStack {
                        Text(event.title)
                            .bold()
                            .font(.title3) // Increase the font size for the title
                            .foregroundColor(.white)
                            .padding(.leading, 20) // Add padding to the leading edge
                        Spacer()
                        Text("\(event.likedBy.filter { eventsViewModel.friendsList.contains($0) }.count) likes")
                            .font(.body) // Increase the font size for the likes
                            .foregroundColor(.gray)
                            .padding(.trailing, 20) // Add padding to the trailing edge
                    }
                    .padding(.vertical, 5) // Adjust vertical padding for each item
                }
            }
        }
        .frame(maxHeight: .infinity) // Remove fixed height to allow dynamic content height
        .background(Color.black.opacity(0.7)) // Set background color with opacity to blend with the expanded black screen
        .cornerRadius(30) // Match the corner radius with the expanded black screen if needed
        .padding(.horizontal, 10) // Add padding to the sides if you want more space from the edges
    }
    
}
