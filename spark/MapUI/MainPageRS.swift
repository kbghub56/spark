//
//  MainPageRS.swift
//  spark
//
//  Created by Kabir Borle on 2/27/24.
//

struct NilButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

import SwiftUI
import UIKit
import MapKit
import Combine

struct HomeMapView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @StateObject private var mapState = MapState()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userManager: UserManager
    private var locationManager = LocationManager(userManager: UserManager()) //Used to be a state object jun 15
    @State private var isCurrentLocationAvailable = false
    @State private var showingFollowRequestPopup = false
    @State private var selectedEvent: EventAnnotation?
    @State private var selectedFriend: FriendAnnotation?
    @State private var showClickEvent = false
    @State private var showFriendProf = false
    @Namespace private var animationNamespace
    @State private var modalOffset: CGFloat = 0
    @State private var didSelectUserAnnotation = true
    @State private var shouldRecenterMap = false
    
    
    @State private var isForYouSelected = false
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
    @State private var showEmojis = true
    @State private var initialRegionSet = false
    @State private var cancellables = Set<AnyCancellable>()
    
    private func handleFollowRequestVisibility() {
        if followRequests.isEmpty {
            showingFollowRequestPopup = false
            currentRequestIndex = 0  // Reset the index for any future follow requests
        }
    }
    
    
   // let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()  // 300 seconds equals 5 minutes
    
    
    var body: some View {
        if locationManager.checkIfLocationNoAuth() {
            WhenLocationOff(showingLocationOffView: $showingLocationOffView)
                .environmentObject(userManager)
                .environmentObject(authViewModel)
        } else {
            ZStack {
                if showingLocationOffView {
                    // WhenLocationOff view is shown directly in the main view hierarchy
                    WhenLocationOff(showingLocationOffView: $showingLocationOffView)
                        .environmentObject(userManager)
                        .environmentObject(authViewModel)
                } else {
                    if isCurrentLocationAvailable {
                        
                        
                        
                        MapViewRepresentable(eventsViewModel: eventsViewModel, locationManager: locationManager, mapState: mapState, authViewModel: authViewModel, userManager: userManager, selectedEvent: $selectedEvent, selectedFriend: $selectedFriend, showMenu: $showMenu, didSelectUserAnnotation: $didSelectUserAnnotation, region: $region, shouldRecenterMap: $shouldRecenterMap, initialRegionSet: $initialRegionSet)
                            .edgesIgnoringSafeArea(.all)
                            .environment(\.colorScheme, .dark)
                            //.onReceive(timer) { _ in
                              //  eventsViewModel.fetchEvents()  // Call fetchEvents every 5 minutes
                            //}
                    }
                    
                    VStack(spacing: 0) {
                        HStack {
                            Spacer(minLength: 0)
                            circleButton
                        }.padding(.horizontal, 16)
                            .padding(.bottom, 25)
                        
                        HStack {
                            Spacer(minLength: 0)
                            toggleSection
                        }.padding(.horizontal, 16)
                            .padding(.bottom, 25)
                        
                        HStack {
                            Spacer(minLength: 0)
                            // Spacer()
                            recenterButton
                        }.padding(.horizontal, 16)
                        
                        Spacer(minLength: 0)
                    }.padding(.bottom, 90)
                        .padding(.top, 16)
                    
                    VStack(){
                        Spacer()
                        if showExpandedBlackScreen {
                        } else /*if !showMenu */{
                            let swipeUpThreshold: CGFloat = -50
                            
                            RoundedRectangle(cornerRadius: 35)
                                .fill(Color.black)
                                .frame(height: (UIScreen.main.bounds.height / 7.5))
                                .edgesIgnoringSafeArea(.bottom)
                                .overlay(
                                    VStack(){
                                        RoundedRectangle(cornerRadius: 2.5)
                                            .frame(width: 40, height: 5, alignment: .center)
                                            .padding(.top, 11)
                                            .foregroundColor(Color(white:0.8))
                                        Spacer()
                                    }
                                )
                            //  .animation(.easeOut(duration: 1), value: showMenu)
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            if gesture.translation.height < swipeUpThreshold {
                                                //     withAnimation {
                                                showExpandedBlackScreen = true
                                                showEmojis = false
                                                //       }
                                            }
                                        }
                                )
                                .onTapGesture {
                                    //        withAnimation {
                                    showExpandedBlackScreen = true
                                    showEmojis = false
                                    //        }
                                }
                        }
                    }.edgesIgnoringSafeArea(.all)
                    
                    GeometryReader { _ in
                        VStack {
                            Spacer()
                            if showExpandedBlackScreen{
                                ZStack{
                                    mapModal
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 50).fill(Color.black).frame(height: UIScreen.main.bounds.height / 8).offset(y:400).onTapGesture{withAnimation{showExpandedBlackScreen = true}}
                            }
                            //  mapModal
                        }.padding(.horizontal, 0)
                    }.ignoresSafeArea(.all)
                    
                    //   if showMenu {
                    SideMenu(showMenu: $showMenu, isSwitchOn: $isSwitchOn, showingLocationOffView: $showingLocationOffView, didSelectUserAnnotation: $didSelectUserAnnotation, locationManager: locationManager, namespace: animationNamespace, dismiss: {
                        // Dismiss the side menu
                        withAnimation {
                            showMenu = false
                        }
                    })
                    //   .transition(.move(edge: .trailing))
                    .environmentObject(userManager)
                    .environmentObject(authViewModel)
                    .animation(.easeInOut, value: showMenu)
                    .offset(x: showMenu ? 0 : UIScreen.main.bounds.width)
                    //   .matchedGeometryEffect(id: "circle", in: namespace)
                    //   }
                    
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
            }
            .overlay(
                Group {
                    if let selectedEvent = selectedEvent, showClickEvent {
                        ClickEvent(isPresented: $showClickEvent, event: selectedEvent) {
                            self.selectedEvent = nil
                        }
                        .zIndex(1)
                    }
                    else if let selectedFriend = selectedFriend, showFriendProf {
                        FriendPopup(isPresented: $showFriendProf, friend: selectedFriend) {
                            // Handle tap outside event
                            self.selectedFriend = nil
                            //  withAnimation {
                            showFriendProf = false
                            //   }
                        }
                        .zIndex(1)
                    }
                }
            )
            .onChange(of: selectedEvent) { newValue in
                //  withAnimation {
                showClickEvent = newValue != nil
                //      }
            }
            .onChange(of: selectedFriend) { newValue in
                showFriendProf = newValue != nil
            }
            .onTapGesture {
                // withAnimation {
                if showExpandedBlackScreen {
                    showExpandedBlackScreen = false
                    showEmojis = true
                }
                if showMenu {
                    showMenu = false
                }
                //   }
            }
            .onAppear {
                // This might be redundant if you're already setting the user in UserManager's init
                userManager.getCurrentUser { _ in }
                locationManager.requestLocationPermission()
                
                // Wait for the current location to be available
                locationManager.$currentLocation
                    .sink { location in
                        if location != nil {
                            isCurrentLocationAvailable = true
                        }
                    }
                    .store(in: &cancellables)
                
                if let currentLocation = locationManager.currentLocation {
                    region = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    initialRegionSet = true
                    print("set init region")
                }
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

    var mapModal: some View {
        VStack {
            RoundedRectangle(cornerRadius: 2.5)
                .frame(width: 40, height: 5, alignment: .center)
                .padding(.top, 7)
                .foregroundColor(Color(white: 0.8))

            HStack {
                Text("Friends")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(selectedTab == 0 ? Color.white : Color.gray)
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 0
                        }
                    }

                Spacer()

                Text("Events")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(selectedTab == 1 ? Color.white : Color.gray)
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 1
                        }
                    }
            }
            .frame(maxWidth: 250)
            .padding(.top, 10)

            TabView(selection: $selectedTab) {
                VStack {
                    FriendsDistanceListView()
                        .environmentObject(userManager)
                        .environmentObject(locationManager)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top)

                    FriendsView().frame(height: 100)
                        .padding(.bottom)
                }
                .tag(0)

                VStack {
                    RankedEventsListView()
                        .environmentObject(eventsViewModel)
                        .environmentObject(locationManager)
                        .padding(.horizontal)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top)

                    EventsView().frame(height: 100)
                        .padding(.bottom)
                }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .frame(height: 650)
        .background(Color.black)
        .cornerRadius(30)
        .transition(.move(edge: .bottom))
        .offset(y: modalOffset)
        .gesture(
            DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                modalOffset = value.translation.height
                            } else {
                                modalOffset = 0
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                if value.translation.height > 100 {
                                    showExpandedBlackScreen = false
                                    showEmojis = true
                                }
                                modalOffset = 0
                            }
                        }
            )
            .gesture(
                DragGesture().onEnded { value in
                    withAnimation {
                        if value.translation.width < 0 {
                            selectedTab = min(selectedTab + 1, 1)
                        } else if value.translation.width > 0 {
                            selectedTab = max(selectedTab - 1, 0)
                        }
                    }
                }
            )
            .onTapGesture {}
    }


    var toggleSection: some View {
        HStack(spacing: 10) {
            VStack(alignment: .trailing, spacing: 0) {
                Text("All")
                    .font(.system(size: 13).bold())
                    .foregroundColor(isForYouSelected ? .gray : .white)
                Spacer(minLength: 0)
                Text("For You")
                    .font(.system(size: 13).bold())
                    .foregroundColor(isForYouSelected ? .white : .gray)
            }.shadow(color: .black.opacity(1), radius: 20, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                .padding(.vertical, 12)
            Button(action: {
                withAnimation {
                    isForYouSelected.toggle()
                    eventsViewModel.filterEvents(forFriendsAndMutuals: isForYouSelected)
                }
            }, label: {
                ZStack {
                    Rectangle()
                        .background(Material.regular)
                        .cornerRadius(50)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44 - 3 * 2, height: 44 - 3 * 2)
                        .offset(x: 0, y: isForYouSelected ? 23 : -23)
                }
            }).frame(width: 44)
                .buttonStyle(NilButtonStyle())
        }.frame(height: 90)
    }

//    var toggleSection: some View {
//        ZStack {
//            Rectangle().foregroundColor(.clear).frame(width: 100, height: 50).background(Color.white.opacity(0.6)).cornerRadius(50).offset(x: -125, y: -380)
//            Text("All").font(.system(size: 13).bold()).foregroundColor(!isForYouSelected ? .white : .gray).offset(x: -155, y: -335)
//            Text("For You").font(.system(size: 13).bold()).foregroundColor(isForYouSelected ? .white : .gray).offset(x: -100, y: -335)
//            Button(action: {
//                withAnimation {
//                    isForYouSelected.toggle()
//                    eventsViewModel.filterEvents(forFriendsAndMutuals: isForYouSelected) // Filter events based on toggle state
//                }
//            }) {
//                Circle().fill(Color.black).frame(width: 45, height: 45)
//            }.offset(x: isForYouSelected ? -130 - 17.5 : -160 + 57.5, y: -375 - 5)
//        }
//    }
//
    var circleButton: some View {
        Button(action: {
            withAnimation {
                didSelectUserAnnotation = false
                showMenu = true
            }
        }) {
            ZStack {
                Circle().fill(Color.white) // White circle background
                    .frame(width: 50, height: 50) // Size of the white circle

                // Check if a Bitmoji URL exists and is valid
                if let bitmojiUrl = authViewModel.snapchatBitmojiAvatarUrl, let url = URL(string: bitmojiUrl) {
                    AsyncImage(url: url) { imagePhase in
                        // Handle different states of the image loading process
                        if let image = imagePhase.image {
                            image.resizable() // Make the image resizable
                                .aspectRatio(contentMode: .fill) // Fill the content in its aspect ratio
                                .frame(width: 40, height: 40) // Slightly smaller than the white circle for padding
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
    }

    var recenterButton: some View {
        Button(action: {
            recenterMap()
        }) {
            Image(systemName: "paperplane.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44 - 3 * 2, height: 44 - 3 * 2)
                .foregroundColor(.white)
        }
    }

    func recenterMap() {
        if let currentLocation = locationManager.currentLocation {
            region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            shouldRecenterMap = true
        }
    }
}


struct FriendsView: View {
    @State private var showingAddFriendView = false
    @EnvironmentObject var userManager: UserManager
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                showingAddFriendView = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Friends")
                }
                .font(.system(size: 17, weight: .bold))
                .frame(width: 200, height: 54)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(10)
            }
            .sheet(isPresented: $showingAddFriendView) {
                AddFriends(showingAddFriendView: $showingAddFriendView) // Pass the binding
                    .environmentObject(userManager)
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
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Events")
                }
                .font(.system(size: 17, weight: .bold))
                .frame(width: 200, height: 54)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(10)
            }
            .sheet(isPresented: $showingEventInputView) {
                AddEvents() // Ensure AddEvents view is implemented in your project
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
    @Binding var didSelectUserAnnotation: Bool // Add this binding
    var locationManager = LocationManager(userManager: UserManager())
    var namespace: Namespace.ID
    var dismiss: () -> Void // Add this closure
    @State private var showDeleteConfirmation = false


    var body: some View {
        ZStack {
            // Semi-transparent background with tap gesture to hide the menu
            if showMenu && !didSelectUserAnnotation{
                Color.black.opacity(showMenu ? 0.5 : 0).edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showMenu = false
                                    }
                                }
            }
            // SideMenu content
            if showMenu {
                VStack {
                    Spacer()

                    VStack(alignment: .leading) {
                        profileSection
                        locationToggle
                        collagesSection
                        signOutButton
                        deleteAccountButton
                        Spacer()
                    }
                    .frame(width: 385, height: 500)
                    .background(Color.black)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    // Empty gesture to 'capture' taps without triggering the background's gesture
                    .onTapGesture {}

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(showMenu ? 1 : 0) // Controls the opacity of the menu
                .animation(.easeInOut, value: showMenu) // Applies an animation based on the state of `showMenu`
            }
        }
        .edgesIgnoringSafeArea(.all)
        .modifier(SideMenuTransition(isPresented: showMenu, onCompletion: dismiss)) // Apply the modifier

    }
    var profileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 25) {
                ZStack{
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 75, height: 75)
                    if let bitmojiUrl = authViewModel.snapchatBitmojiAvatarUrl, let url = URL(string: bitmojiUrl) {
                        AsyncImage(url: url) { imagePhase in
                            // Handle different states of the image loading process
                            if let image = imagePhase.image {
                                image.resizable() // Make the image resizable
                                    .aspectRatio(contentMode: .fill) // Fill the content in its aspect ratio
                                    .frame(width: 60, height: 60) // Slightly smaller than the white circle for padding
                                    .clipShape(Circle()) // Clip the image to a circle
                            } else if imagePhase.error != nil {
                                Color.gray // Display a gray area in case of an error
                            } else {
                                ProgressView() // Show a progress indicator while loading
                            }
                        }
                    }
                }

//                    .overlay(
//                        Button(action: {}, label: {
//                            Text("Change")
//                                .font(.system(size: 13))
//                                .foregroundColor(.black)
//                                .padding(8)
//                                .padding(.horizontal, 3)
//                                .background(Color.white)
//                                .cornerRadius(50)
//                        })
                //                        .offset(x: 0, y: 38)
                //                    )
                VStack(alignment: .leading, spacing: 5) {
                    if let username = userManager.currentUser?.userName {
                        Text(username).font(.system(size: 28).bold()).foregroundColor(.white)
                            .font(.system(size: 20).bold())
                            .foregroundColor(.white)
                    } else {
                        Text("Unknown User").font(.system(size: 28).bold()).foregroundColor(.white)
                            .font(.system(size: 20).bold())
                            .foregroundColor(.white)
                    }
                    HStack{
                        Text("SparkID:")
                            .font(.system(size: 17))
                            .bold()
                            .foregroundColor(.white)
                        Text(userManager.currentUser?.uniqueUserID ?? "Not Found")
                            .font(.system(size: 17))
                            .bold()
                            .underline()
                            .foregroundColor(.white)
                        ShareLink(item: sparkIdShareString()) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                    }

                    Text(locationManager.nearbyPlace ?? "Unknown Place")
                        .font(.system(size: 17).bold())
                        .foregroundColor(.white)

                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 32)
        }
    }
    var locationToggle: some View {
        HStack {
            Text("Location:")
                .font(.system(size: 24).bold())
                .foregroundColor(.white)

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 100, height: 50)

                Circle()
                    .fill(Color.white)
                    .frame(width: 45, height: 45)
                    .offset(x: isSwitchOn ? -25 : 25)

                HStack {
                    Text("On")
                        .font(.system(size: 13).bold())
                        .foregroundColor(isSwitchOn ? .white : .gray)

                    Text(" ")

                    Text("Off")
                        .font(.system(size: 13).bold())
                        .foregroundColor(isSwitchOn ? .gray : .white)
                }
                .offset(y: 40)
            }
            .onTapGesture {
                withAnimation {
                    isSwitchOn.toggle()
                    locationManager.isLocationSharingEnabled = isSwitchOn
                    if !isSwitchOn {
                        showingLocationOffView = true // Present WhenLocationOff view
                        userManager.updateUserLocationOffStatus(isLocationOff: true)
                        print(userManager.isLocationOff)
                    } else {
                        userManager.updateUserLocationOffStatus(isLocationOff: false)
                    }
                }
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 32)
    }
    var collagesSection: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Your Collages 📷:")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            HStack {
                Spacer()
                Image("PNG image 1")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .cornerRadius(15)
                    .blur(radius: 1.5)
                Image("PNG image 2")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .cornerRadius(15)
                    .blur(radius: 1.5)
                Spacer()
            }
            HStack {
                Spacer()
                Image("PNG image 3")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .cornerRadius(15)
                    .blur(radius: 1.5)
                Image("PNG image")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .cornerRadius(15)
                    .blur(radius: 1.5)
                Spacer()
            }
        }
        .overlay(
            VStack {
                Image(systemName: "lock.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .scaleEffect(0.75)
                Text("coming soon ...")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .scaleEffect(0.75)
            }
        ).frame(maxWidth: .infinity)
    }
    var signOutButton: some View {
        VStack{
    //        Spacer()
            Button("Sign Out") {
                authViewModel.logOut()
            }
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal, 5)
            .background(Color.black)
            .cornerRadius(50)

            Spacer().frame(height: 5) // Add a spacer with a fixed height

        }.frame(maxWidth: .infinity)

    }

    var deleteAccountButton: some View {
        VStack {
            Button("Delete Account") {
                // Show confirmation popup
                showDeleteConfirmation = true
            }
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal, 5)
            .background(Color.black)
            .cornerRadius(50)

        }
        .frame(maxWidth: .infinity)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // Call the deleteAccount function from AuthViewModel
                    authViewModel.deleteAccount { success in
                        if success {
                            // Navigate back to the sign-up view
                            authViewModel.isUserAuthenticated = false
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func sparkIdShareString() -> String {
        guard let sparkID = userManager.currentUser?.uniqueUserID else {
            return "SparkID not found"
        }
        return "Add my SparkID: \(sparkID)\n\nSent from SparkRice⚡"
    }

//    func shareSparkID() {
//        guard let sparkID = userManager.currentUser?.uniqueUserID else {
//            print("SparkID not found")
//            return
//        }
//
//        let activityViewController = UIActivityViewController(activityItems: ["Add my SparkID: \(sparkID)\n\nSent from SparkRice⚡"], applicationActivities: nil)
//
//        // Exclude certain activity types if desired
//        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact]
//
//        // Present the share sheet
//        if let windowScene = UIApplication.shared.windows.first?.windowScene {
//            windowScene.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
//        }
//    }


}



struct FollowRequestPopup: View {
    @EnvironmentObject var userManager: UserManager
    var request: FollowRequest
    var onAccept: () -> Void // Closure called when accept is tapped
    var onReject: () -> Void // Closure called when reject is tapped

    var body: some View {
        VStack(spacing:40){
            Text("New Friends?")
                .font(.title)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            HStack {
                            LargeBitmojiView(bitmojiUrl: request.bitmojiUrl)

                            Text(request.fromUsername)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                        }
            .padding(.trailing)
            .frame(maxWidth: .infinity, alignment: .center) // Add frame modifier

            HStack(spacing: 45) {
                Button("Accept") {
                    onAccept() // Call the accept closure provided by the parent view
                }
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .bold))
                .padding()
                .scaleEffect(0.8)
                .background(Color.black)
                .cornerRadius(10)

                Button("Reject") {
                    onReject() // Call the reject closure provided by the parent view
                }
                .foregroundColor(.white)
                .scaleEffect(0.8)
                .font(.system(size: 22, weight: .bold))
                .padding()
                .background(Color.black)
                .cornerRadius(10)
            }
        }
        .frame(width: 350, height: 350)
        .background(Color.white)
        .cornerRadius(50)
        .shadow(radius: 10)
        .padding()
    }
}

struct LargeBitmojiView: View {
    let bitmojiUrl: String

    var body: some View {
        if let url = URL(string: bitmojiUrl) {
            AsyncImage(url: url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100) // Adjust the size as needed
                    .clipShape(Circle())
            } placeholder: {
                Circle().fill(Color.gray).frame(width: 100, height: 100) // Adjust the size as needed
            }
        }
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


struct RankedEventsListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State private var showClickEvent: Bool = false
    @State private var selectedEvent: EventAnnotation? = nil


    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(eventsViewModel.sortedEventsByLikesFromFriends, id: \.id) { event in
                    VStack {
                        HStack {
                            if event.visibility == "Everyone" {
                                Text("🎉")
                                    .font(.system(size: 50))
                                    .padding(.leading, 10)
                            } else if event.visibility == "Friends and Mutuals Only" {
                                Text("🤗")
                                    .font(.system(size: 50))
                                    .padding(.leading, 10)
                            } else if event.visibility == "Friends Only" {
                                Text("😁")
                                    .font(.system(size: 50))
                                    .padding(.leading, 10)
                            } else {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2)
                                    .background(Circle().fill(Color.gray.opacity(0.3)))
                                    .frame(width: 60, height: 60)
                                    .padding(.leading, 10)
                            }


                            VStack(alignment: .leading, spacing: 4) {

                                Text(event.title)
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .offset(y:-9)




                                Text(truncateLocation(event.locTitle, event.locSubtitle))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .offset(y: -9)
                                Text(calculateDistanceToEvent(event: event))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .offset(y: -9)
                                HStack {
                                    Spacer()

                                    Button(action: {
                                        self.selectedEvent = EventAnnotation(event: event)
                                        self.showClickEvent = true
                                    }) {
                                        Text("See More")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .overlay(Rectangle().frame(height: 2).foregroundColor(Color.blue), alignment: .bottom)

                                    Spacer()
                                }
                            }
                            .padding(.leading, 10)


                            Spacer()

                            VStack{
                                HStack(spacing: 12) {
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
                                    ShareLink(item: "\(event.title ?? "Event Title")\n" +
                                              "\(event.visibility ?? "Invite Status") [invited]\n" +
                                              "@ \(event.locTitle ?? "Location Title")\n" +
                                              "\(event.locSubtitle ?? "Additional Location Info")\n" +
                                              "\(event.description ?? "Description")\n\n" + "Sent from SparkRice⚡") {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.trailing, 15) // Add padding to the right of the share button
                                    .padding(.top, 1)
                                    .offset(y: -11)
//                                    Button(action: {
//                                        self.shareEvent(event: event)
//                                    }) {
//                                        Image(systemName: "square.and.arrow.up")
//                                            .font(.title)
//                                            .foregroundColor(.white) // Adjust color as needed
//                                    }
//                                    .padding(.trailing, 15) // Add padding to the right of the share button
//                                    .padding(.top, 1)
//                                    .offset(y: -11)
                                }
                                Spacer() // Pushes the content to the top of the VStack
                                // Likes count text
                                // HStack for Bitmojis of friends who liked the event
                                if !event.likedBy.filter({ eventsViewModel.friendsList.contains($0) && authViewModel.friendsBitmojiUrls.keys.contains($0) }).isEmpty {

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
        .overlay(
                    Group {
                        if showClickEvent && selectedEvent != nil {
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation {
                                        showClickEvent = false
                                        selectedEvent = nil
                                    }
                                }
                            VStack {
                               // Spacer()
                                ClickEvent(isPresented: $showClickEvent, event: selectedEvent!) {
                                    self.selectedEvent = nil
                                }
                                .frame(width: 385, height: 450)
                                .background(.black)
                                .cornerRadius(50)
                                .shadow(radius: 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .transition(.scale)
                                .scaleEffect(0.9)
                          //      Spacer()
                            }
                        }
                    }
                )
    }

    func shareEvent(event: Event) {
        let eventDetails = "\(event.title ?? "Event Title")\n" +
        "\(event.visibility ?? "Invite Status") [invited]\n" +
        "@ \(event.locTitle ?? "Location Title")\n" +
        "\(event.locSubtitle ?? "Additional Location Info")\n" +
        "\(event.description ?? "Description")\n\n" + "Sent from SparkRice⚡"

   
        let activityViewController = UIActivityViewController(activityItems: [eventDetails], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }

    // Function to truncate location title and subtitle
    func truncateLocation(_ title: String, _ subtitle: String) -> String {
        print("SORTED EVENTS: \(eventsViewModel.sortedEventsByLikesFromFriends)")
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
    @EnvironmentObject var locationManager: LocationManager
    @State private var showingAddFriendView = false
  //  @State private var showRemoveFriendPopup = false
    @State private var selectedFriendID: String?
 //   @State private var dragOffset: CGFloat = 0
    @State private var showFriendPopup = false
    @State private var selectedFriend: FriendDistance?

    var body: some View {
        if userManager.friendsDistances.isEmpty {
            ScrollView {
                VStack {
                    Button(action: {showingAddFriendView = true
                    }
                    ){
                        Text("Click here to find your friends")
                            .font(.system(size: 24, weight: .bold))
                            .underline()
                            .foregroundColor(.white)
                            .padding(.vertical, 20)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.7))
                .sheet(isPresented: $showingAddFriendView) {
                    AddFriends(showingAddFriendView: $showingAddFriendView) // Pass the binding
                        .environmentObject(userManager)
                }
            }
        }  else {
            ScrollView {
                VStack(spacing: 15) {
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
                                .onTapGesture {
                                                                    selectedFriend = friendDistance
                                                                    showFriendPopup = true
                                                                }
                            }



                            VStack(alignment: .leading, spacing: 2) {
                                Text(friendDistance.userName)
                                    .foregroundColor(.white)
                                    .font(.system(size: 25))

                                Text(friendDistance.nearbyPlace?.trimmedAddress() ?? "")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .padding(.leading, 10)

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

                                // Activity status
                                let status = activityStatus(for: friendDistance.lastActive!)
                                Text(status.text)
                                    .foregroundColor(status.color.opacity(status.opacity))
                                    .font(.system(size: 14))  // Font size for "Active/Away" captions
                            }

//                            // Add remove button
//                            Button(action: {
//                                guard let currentUserUniqueID = userManager.currentUser?.uniqueUserID else {
//                                    print("Current user unique ID not found")
//                                    return
//                                }
//                                DispatchQueue.main.async {
//                                    userManager.removeAsFriend(currentUserUniqueID: currentUserUniqueID, friendID: friendDistance.id)
//                                }
//                            }) {
//                                Image(systemName: "xmark")
//                                    .foregroundColor(.red)
//                                    .font(.system(size: 20))
//                            }
//                            .padding(.leading, 10)
                        }
                    //    .offset(x: dragOffset)
                        .padding(.vertical, 10) // Adjusted vertical padding for each row to balance spacing
//                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                                                    Button(action: {
//                                                        selectedFriendID = friendDistance.id
//                                                        showRemoveFriendPopup = true
//                                                    }) {
//                                                        Image(systemName: "xmark")
//                                                    }
//                                                    .tint(.red)
//                                                }
                    }.padding(.top, 10)
                    Spacer()
                }.padding() // Add padding if necessary
            }
            .background(Color.black.opacity(0.7))
            .overlay(
                            Group {
                                if showFriendPopup, let friend = selectedFriend {
                                    Color.black.opacity(0.4)
                                        .edgesIgnoringSafeArea(.all)
                                        .onTapGesture {
                                            withAnimation {
                                                showFriendPopup = false
                                                selectedFriend = nil
                                            }
                                        }
                                    VStack{
                                        FriendPopup(isPresented: $showFriendPopup, friend: FriendAnnotation(coordinate: CLLocationCoordinate2D(latitude: 23.92, longitude: 32.90), title: friend.id, subtitle: "", nearbyPlace: friend.nearbyPlace, userName: friend.userName, locationLastUpdated: friend.lastActive, bitmojiUrl : friend.bitmojiUrl)) {
                                            selectedFriend = nil
                                        }
                                        .frame(width: 385, height: 450) // Adjust the size as needed
                                        .background(.black)
                                        .cornerRadius(50)
                                        .shadow(radius: 20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 50)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                        .transition(.scale)
                                        .scaleEffect(0.9)
                                    }

                                }
                            }
                        )

        }
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
extension String {
    func trimmedAddress() -> String {
        let components = self.components(separatedBy: ", ")
        if components.count >= 3 {
            return components[0...3].joined(separator: ", ")
        }
        return self  // Return the original string if it doesn't have enough components
    }
}
//opacity(0.2/0.3)
