//
//  UITest.swift
//  spark
//
//  Created by Kabir Borle on 2/24/24.
//

import SwiftUI

import MapKit



struct MainPage: View {

    @State private var isForYouSelected = true

    @State private var showMenu = false

    @State private var showExpandedBlackScreen = false

    @State private var selectedTab = 0 // State to control selected tab

    @State private var region = MKCoordinateRegion(

        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),

        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

    )

    @State private var trackingMode: MapUserTrackingMode = .follow

    @State private var isSwitchOn = true



    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $trackingMode)
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, .dark)

            toggleSection
            circleButton
            
            if showExpandedBlackScreen {
                expandedBlackScreenView
            } else {
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.black)
                    .frame(height: UIScreen.main.bounds.height / 8)
                    .offset(y: 400)
                    .onTapGesture {
                        withAnimation {
                            showExpandedBlackScreen = true
                        }
                    }
            }

            if showMenu {
                SideMenu(showMenu: $showMenu, isSwitchOn: $isSwitchOn)
                    .transition(.move(edge: .trailing))
            }

            
        }
        .onTapGesture {
            withAnimation {
                if showExpandedBlackScreen {
                    showExpandedBlackScreen = false
                }
            }
        }
    }

    var expandedBlackScreenView: some View {
        VStack {
            HStack(spacing: 20) {
                Text("Friends")
                    .font(.system(size: 22, weight: selectedTab == 0 ? .bold : .regular))
                    .foregroundColor(selectedTab == 0 ? .white : .gray)
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 0
                        }
                    }

                Spacer()

                Text("Events")
                    .font(.system(size: 22, weight: selectedTab == 1 ? .bold : .regular))
                    .foregroundColor(selectedTab == 1 ? .white : .gray)
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 1
                        }
                    }
            }
            .padding(.horizontal, 60) // Adjust horizontal padding to bring texts closer

            TabView(selection: $selectedTab) {
                FriendsView()
                    .tag(0)
                EventsView()
                    .tag(1)
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
        .onTapGesture {
            // This empty gesture handler will consume tap events, preventing them from reaching the ZStack's onTapGesture
        }
    }



    var toggleSection: some View {

        ZStack {

            Rectangle()

                .foregroundColor(.clear)

                .frame(width: 100, height: 50)

                .background(Color.white.opacity(0.6))

                .cornerRadius(50)

                .offset(x: -125, y: -380)

            Text("All")

                .font(.system(size: 13).bold())

                .foregroundColor(isForYouSelected ? .white : .gray)

                .offset(x: -155, y: -335)

            Text("For You")

                .font(.system(size: 13).bold())

                .foregroundColor(isForYouSelected ? .gray : .white)

                .offset(x: -100, y: -335)

            Button(action: {

                withAnimation {

                    isForYouSelected.toggle()

                }

            }) {

                Circle()

                    .fill(Color.black)

                    .frame(width: 45, height: 45)

            }

            .offset(x: isForYouSelected ? -130 - 17.5 : -160 + 57.5, y: -375 - 5)

        }

    }

    var circleButton: some View {

        Button(action: {

            withAnimation {

                showMenu = true

            }

        }) {

            Circle()

                .fill(Color.white)

                .frame(width: 75, height: 75)

        }

        .offset(x: 133.50, y: -378.50)

    }

}



struct FriendsView: View {

    var body: some View {

        VStack {

            // Your friends list content here...



            Spacer() // Pushes the button to the bottom



            Button(action: {

                // Action for Add Friends button

            }) {

                HStack {

                    Image(systemName: "plus") // System plus icon

                        .font(.title) // Makes the icon larger and thicker

                    Text("Add Friends")

                        .font(.system(size: 22, weight: .bold))



                }

                .foregroundColor(.black) // Black text and icon

                .padding()

                .background(Color.white) // White background

                .cornerRadius(10)

            }

            .padding(.bottom, 20)

        }

    }

}



struct EventsView: View {

    var body: some View {

        VStack {

                Spacer()



                Button(action: {

                    // Action for Add Events button

                }) {

                    HStack {

                        Image(systemName: "plus")

                            .font(.title)

                        Text("Add Events")

                            .font(.system(size: 22, weight: .bold))



                    }

                    .foregroundColor(.black) // Black text and icon

                    .padding()

                    .background(Color.white) // White background

                    .cornerRadius(10)

                }

                .padding(.bottom, 20)

            }

        }

    }



struct SideMenu: View {

    @Binding var showMenu: Bool

    @Binding var isSwitchOn: Bool



    var body: some View {

        ZStack(alignment: .topTrailing) {

            Color.black

                .frame(width: UIScreen.main.bounds.width * 3 / 4, height: UIScreen.main.bounds.height)

                .cornerRadius(35)

                .offset(y: -12.5)

                .overlay(

                    VStack(alignment: .leading) {

                        Circle()

                            .fill(Color.white.opacity(0.5)) // Light grey circle in dark mode

                            .frame(width: 100, height: 100)

                            .padding(.top, 20)

                            .offset(y:0)
                        Group{
                            
                            Text("username")
                            
                                .font(.system(size: 28).bold())
                            
                                .foregroundColor(.white) // Text to white for dark mode
                            
                                .offset(x: 120, y:-120)
                            
                                .padding(.top, 10)
                            
                            Text("near this location")
                            
                                .font(.system(size: 20).bold())
                            
                                .foregroundColor(.white) // Text to white for dark mode
                            
                                .offset(x: 120, y:-120)
                            
                                .padding(.top, 5)
                            
                            Text("Location:")
                            
                                .font(.system(size: 24).bold())
                            
                                .foregroundColor(.white) // Text to white for dark mode
                            
                                .offset(y: -45)
                        }

                        VStack {

                            Rectangle()

                                .foregroundColor(.clear)

                                .frame(width: 100, height: 50)

                                .background(Color.white.opacity(0.6))

                                .cornerRadius(50)

                                .offset(x: 150, y: -125)

                            HStack{

                                Text("On")

                                    .font(.system(size: 13).bold())

                                    .foregroundColor(isSwitchOn ? .white : .gray) // Adjusted for dark mode

                                    .offset(x: -6)

                                

                                Text("Off")

                                    .font(.system(size: 13).bold())

                                    .foregroundColor(isSwitchOn ? .gray : .white) // Adjusted for dark mode

                                    .offset(x: 6)

                            }

                            .offset(x:150, y: -125)

                        }

                        .padding(.top, 20)

                        Button(action: {

                            withAnimation {

                                isSwitchOn.toggle()

                            }

                        }) {

                            Circle()

                                .fill(Color.white) // Circle fill to white for dark mode

                                .frame(width: 45, height: 45)

                        }

                        .offset(x: isSwitchOn ? -25 : 25)

                        .offset(x:175, y: -200)

                        Button("Change") {

                            // Action for the Change button

                        }

                        .foregroundColor(.black)

                        .padding()

                        .background(Color.white) // Keeping the original style

                        .cornerRadius(50)

                        .padding(.top, 10)

                        .scaleEffect(0.8)

                        .offset(x: 2.5, y: -325)

                        Button("Sign Out") {

                            // Action for the Sign Out button

                        }

                        .font(.system(size: 24).bold())

                        .foregroundColor(.black)

                        .padding()

                        .background(Color.white) // Keeping the original style

                        .cornerRadius(50)

                        .padding(.top, 10)

                        .scaleEffect(1)

                        .offset(x: 75, y: 210)

                        Text("Your 📷 Collages:")

                            .font(.system(size: 28).bold())

                            .foregroundColor(.white) // Text to white for dark mode

                            .padding(.top, 20)

                            .offset(x: 25, y: -280)

                        // Images row with the original color

                        HStack {

                            Image("PNG image 1")

                                .resizable()

                                .scaledToFit()

                                .frame(width: 100, height: 100)

                                .cornerRadius(15)

                                .blur(radius: 1.5)

                            Image("PNG image 2")

                                .resizable()

                                .scaledToFit()

                                .frame(width: 100, height: 100)

                                .cornerRadius(15)

                                .blur(radius: 1.5)

                        }

                        .offset(x: 27.5, y: -270)

                        .padding(.top, 20)

                        HStack {

                            Image("PNG image 3")

                                .resizable()

                                .scaledToFit()

                                .frame(width: 100, height: 100)

                                .cornerRadius(15)

                                .blur(radius: 1.5)

                            Image("PNG image") // Assuming the last image is named "PNG image 4"

                                .resizable()

                                .scaledToFit()

                                .frame(width: 100, height: 100)

                                .cornerRadius(15)

                                .blur(radius: 1.5)

                        }

                        .offset(x: 27.5, y: -270)

                        .padding(.top, 10)

                        .overlay(

                            VStack {

                                Image(systemName: "lock.fill")

                                    .font(.largeTitle)

                                    .foregroundColor(.white)

                                Text("coming soon ...")

                                    .font(.title)

                                    .foregroundColor(.white)

                            }

                                .offset(x: 27.5, y: -325)

                        )

                        Spacer()

                    }

                    .padding(),

                    alignment: .topLeading

                )

            

            GeometryReader { geometry in
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        showMenu = false
                                    }
                                }
                                // Set the frame to cover only the left fourth of the screen
                                .frame(width: geometry.size.width / 4, height: geometry.size.height)
                                // No need to offset as it starts from the left edge by default
                        }

        }

//        .frame(maxWidth: .infinity, alignment: .trailing)

//        .contentShape(Rectangle())

//        .onTapGesture {

//            withAnimation {

//                showMenu = false

//            }

//        }

    }

}

struct MainPage_Previews: PreviewProvider {

    static var previews: some View {

        MainPage()

    }

}

