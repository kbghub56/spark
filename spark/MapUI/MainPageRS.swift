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
            if locationManager.isLocationSharingEnabled {
                MapViewRepresentable(eventsViewModel: eventsViewModel, locationManager: locationManager, mapState: mapState, authViewModel: authViewModel, userManager: userManager)
                    .edgesIgnoringSafeArea(.all)
                
                toggleSection
                circleButton
                
                if showExpandedBlackScreen {
                    ZStack{
                        expandedBlackScreenView
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
                    SideMenu(showMenu: $showMenu, isSwitchOn: $isSwitchOn, showingLocationOffView: $showingLocationOffView, locationManager: locationManager)
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
            else{
                WhenLocationOff()
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
        .onChange(of: showExpandedBlackScreen) { isOpen in
            if isOpen {
                // If the expanded view is open and there's a valid current location, update friends' distances
                if let currentLocation = locationManager.currentLocation {
                    userManager.updateFriendsDistances(currentLocation: currentLocation)
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
            ZStack {
                Circle().fill(Color.white) // White circle background
                    .frame(width: 75, height: 75) // Size of the white circle

                // Check if a Bitmoji URL exists and is valid
                if let bitmojiUrl = authViewModel.snapchatBitmojiAvatarUrl, let url = URL(string: bitmojiUrl) {
                    AsyncImage(url: url) { imagePhase in
                        // Handle different states of the image loading process
                        if let image = imagePhase.image {
                            image.resizable() // Make the image resizable
                                 .aspectRatio(contentMode: .fill) // Fill the content in its aspect ratio
                                 .frame(width: 65, height: 65) // Slightly smaller than the white circle for padding
                                 .clipShape(Circle()) // Clip the image to a circle
                        } else if imagePhase.error != nil {
                            Color.gray // Display a gray area in case of an error
                        } else {
                            ProgressView() // Show a progress indicator while loading
                        }
                    }
                }
            }
        }
        .frame(width: 75, height: 75) // Set the frame for the entire button
        .offset(x: 133.50, y: -378.50) // Adjust the offset as needed
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
            
            if selectedTab == 0 {
                VStack {
                    FriendsDistanceListView() // Add the FriendsDistanceListView here
                        .environmentObject(userManager)
                        .background(Color.black.opacity(0.7)) // Semi-transparent black background
                        .cornerRadius(10)
                        .padding(.top) // Add padding at the top if necessary
                    FriendsView()
                }
            }

            // This will show the RankedEventsListView when the Events tab is selected
            if selectedTab == 1 {
                VStack {
                    RankedEventsListView()
                        .environmentObject(eventsViewModel) // Make sure to pass the necessary environment objects
                        .environmentObject(locationManager)
                        .padding(.horizontal) // Add padding if necessary
                        .background(Color.black.opacity(0.7)) // Semi-transparent black background
                        .cornerRadius(10)
                        .padding(.top) // Add padding at the top if necessary
                    EventsView()
                }
            }

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
struct EventsView: View {
    @State private var showingEventInputView = false
    var body: some View {
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
struct SideMenu: View {
    @Binding var showMenu: Bool
    @Binding var isSwitchOn: Bool
    @Binding var showingLocationOffView: Bool
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var authViewModel: AuthViewModel
    var locationManager: LocationManager
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
                            locationManager.isLocationSharingEnabled = isSwitchOn
                            if !isSwitchOn {
                                showingLocationOffView = true // Present WhenLocationOff view
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
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(eventsViewModel.sortedEventsByLikesFromFriends, id: \.id) { event in
                    VStack { // Wrap in a VStack to include the Divider below each event
                        HStack {
                            // Placeholder circle
                            // Replace the placeholder circle with conditional emojis
                                if event.visibility == "Everyone" {
                                    Text("🎉") // Emoji for Everyone
                                        .font(.system(size: 50))
                                        .padding(.leading, 10)// Adjust size as needed
                                } else if event.visibility == "Friends and Mutuals Only" {
                                    Text("🤗") // Emoji for Friends and Mutuals Only
                                        .font(.system(size: 50))
                                        .padding(.leading, 10)// Adjust size as needed
                                } else if event.visibility == "Friends Only" {
                                    Text("😁") // Emoji for Friends Only
                                        .font(.system(size: 50))
                                        .padding(.leading, 10)// Adjust size as needed
                                } else {
                                    Circle() // Fallback to the circle if none of the conditions match
                                        .strokeBorder(Color.white, lineWidth: 2)
                                        .background(Circle().fill(Color.gray.opacity(0.3)))
                                        .frame(width: 60, height: 60)
                                        .padding(.leading, 10)
                                }
                   //             .padding(.leading, 10)
                                
                            
                            
                            VStack(alignment: .leading, spacing: 4) { // Use alignment .leading
                             
                                Text(event.title)
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .offset(y:-9)
            
                                    
                      
                                
                                Text(truncateLocation(event.locTitle, event.locSubtitle))
                                                                    .font(.system(size: 12))
                                                                    .foregroundColor(.white)
                                                                    .offset(y: -9)
                                // Display calculated distance
                                Text(calculateDistanceToEvent(event: event))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .offset(y: -9)
                                Button(action: {
                                    // Leave the action empty for now
                                }) {
                                    Text("See More")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.blue) // Baby blue color
                                }
                                .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid any default button styling
        //                        .padding(.bottom, 5) // Add some padding to space it out from the bottom edge
                                .overlay(Rectangle().frame(height: 2).foregroundColor(Color.blue), alignment: .bottom) // Add underline effect
                            }
                            .padding(.leading, 10) // Apply padding to the VStack to position both texts
                
                            
                            Spacer()
 
                            VStack{
                                HStack(spacing: 12) { // You can adjust the spacing as needed
                                        // Heart button
                                    Button(action: {
                                            let currentUserID = self.authViewModel.currentUserID ?? ""
                                            let isLiked = event.likedBy.contains(currentUserID)
                                            
                                            if isLiked {
                                                eventsViewModel.unlikeEvent(eventID: event.id, currentUserID: currentUserID)
                                            } else {
                                                // Call likeEvent if the event is not currently liked
                                                eventsViewModel.likeEvent(eventID: event.id, currentUserID: currentUserID, isLiked: true)
                                            }
                                        }) {
                                            Image(systemName: event.likedBy.contains(authViewModel.currentUserID ?? "") ? "heart.fill" : "heart")
                                                .font(.title)
                                                .foregroundColor(event.likedBy.contains(authViewModel.currentUserID ?? "") ? .red : Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1.0)) // Red if liked, translucent if not
                                        }
                                        .padding(.top, 4)
                                        .offset(y: -9)

                                        // Share button
                                        Button(action: {
                                            // Share button action
                                        }) {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.title)
                                                .foregroundColor(.white) // Adjust color as needed
                                        }
                                        .padding(.trailing, 15) // Add padding to the right of the share button
                                        .padding(.top, 1)
                                        .offset(y: -9)
                                    }
                                    Spacer() // Pushes the content to the top of the VStack
                                // Likes count text
                                // HStack for Bitmojis of friends who liked the event
                                HStack(spacing: 0){
//                                    
//                                    Text("liked")//.padding(.trailing, 25)
//                                        .font(.system(size: 12))
//                                        .padding(.trailing, 3)
                                    
                                    Image(systemName: "heart.fill")
                                            .foregroundColor(.red) // Set the color to red
                                            .font(.system(size: 12)) // Adjust the size as needed
                                           // .padding(.trailing, 4) // Add some space between the heart and the Bitmojis
                                    HStack(spacing: -10) {
                                        
                                        ForEach(event.likedBy.filter { eventsViewModel.friendsList.contains($0) && authViewModel.friendsBitmojiUrls.keys.contains($0) }, id: \.self) { userId in
                                            if let bitmojiUrl = authViewModel.friendsBitmojiUrls[userId], let url = URL(string: bitmojiUrl) {
                                                AsyncImage(url: url) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image.resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 27, height: 27)
                                                            .clipShape(Circle())
                                                    case .failure(_):
                                                        Circle().fill(Color.gray).frame(width: 27, height: 27)
                                                    case .empty:
                                                        ProgressView()
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                        }
                                    }//.padding(.leading, 17)
                                    Text("&more")
                                            .font(.system(size: 12))
                                            // Adjust padding as needed to align with your design
                                            .padding(.leading, 4)
                                   
                                }
                            }
                            
                            
                        }
                        .padding(.vertical, 10)
                        
                       
                       
                        // Light rectangular border below each event
                        Rectangle()
                            .fill(Color.white.opacity(0.2)) // Light-colored line
                            .frame(height: 1) // Just one pixel high to act as a line
                            .edgesIgnoringSafeArea(.horizontal) // Extend to the screen edges if needed
                            .padding(.bottom, 10)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
        .cornerRadius(30)
        .padding(.horizontal, 15)
 
    }
    
    // Function to truncate location title and subtitle
    func truncateLocation(_ title: String, _ subtitle: String) -> String {
        let combined = "\(title), \(subtitle)"
        if combined.count > 17 {
            let index = combined.index(combined.startIndex, offsetBy: 17)
            return "\(combined[..<index])..."
        } else {
            return combined
        }
    }
    
    // Function to calculate the distance to the event and format the string
    func calculateDistanceToEvent(event: Event) -> String {
        guard let userLocation = locationManager.currentLocation else {
            return "Distance unknown"
        }

        let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
        let distanceInMeters = userLocation.distance(from: eventLocation)
        let distanceInMiles = distanceInMeters / 1609.34 // Convert meters to miles

        if distanceInMiles < 1 {
            return "< 1 mi away"
        } else {
            let roundedDistance = round(distanceInMiles)
            return "\(Int(roundedDistance)) mi away"
        }
    }
}


struct FriendBitmojiView: View {
    let bitmojiUrl: String

    var body: some View {
        if let url = URL(string: bitmojiUrl) {
            AsyncImage(url: url) { image in
                image.resizable()
                     .aspectRatio(contentMode: .fill)
                     .frame(width: 20, height: 20)
                     .clipShape(Circle())
            } placeholder: {
                Circle().fill(Color.gray).frame(width: 20, height: 20)
            }
        }
    }
}


struct FriendsDistanceListView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        ScrollView {
            VStack(spacing: 15) { // Adjusted spacing between rows
                ForEach(userManager.friendsDistances) { friendDistance in
                    HStack {
                        if let bitmojiUrl = friendDistance.bitmojiUrl, let url = URL(string: bitmojiUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle().fill(Color.gray).frame(width: 30, height: 30)
                            }
                        }
                        Text(friendDistance.userName)
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .font(.system(size: 25)) // Font size for the username

                        Spacer()

                        VStack(alignment: .trailing) {
                            // Distance display
                            if friendDistance.distance / 1609.34 < 1 {
                                Text("< 1 mi away")
                                    .foregroundColor(.gray)
                            } else {
                                let miles = (friendDistance.distance / 1609.34).rounded()
                                Text("\(Int(miles)) mi away")
                                    .foregroundColor(.gray)
                            }
                            
                            // Activity status with adjusted font size
                            let status = activityStatus(for: friendDistance.lastActive!)
                            Text(status.text)
                                .foregroundColor(status.color.opacity(status.opacity))
                                .font(.system(size: 14)) // Increased font size for "Active/Away" captions
                        }
                    }
                    .padding(.vertical, 10) // Adjusted vertical padding for each row to balance spacing
                }.padding(.top, 10)
                Spacer()
            }.padding() // Add padding if necessary
        }
        .background(Color.black.opacity(0.7))
    }

    private func activityStatus(for lastActiveDate: Date) -> (text: String, color: Color, opacity: Double) {
        let now = Date()
        let twelveHoursAgo = now.addingTimeInterval(-43200)  // 12 hours = 43,200 seconds

        if lastActiveDate > twelveHoursAgo {
            // Muted green for "Active" status
            let activeColor = Color(red: 137 / 255, green: 198 / 255, blue: 142 / 255)
            return ("Active", activeColor, 0.7)
        } else {
            // Muted red for "Away" status
            let awayColor = Color(red: 255 / 255, green: 150 / 255, blue: 150 / 255) // Lighter shade of red with higher opacity
            return ("Away", awayColor, 0.6)
        }
    }
}



//opacity(0.2/0.3)
