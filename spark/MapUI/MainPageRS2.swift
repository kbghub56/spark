import SwiftUI
import MapKit

struct NilButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct MainPage2: View {
    @State private var isForYouSelected = true
    @State private var showMenu = false
    @State private var showExpandedBlackScreen = true
    @State private var selectedTab = 0
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var isSwitchOn = true
    @State private var showEmojis = true
    @Namespace private var animationNamespace
    
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $trackingMode)
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, .dark)
            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    circleButton2
                }.padding(.horizontal, 16)
                    .padding(.bottom, 25)
                HStack {
                    Spacer(minLength: 0)
                    toggleSection2
                }.padding(.horizontal, 16)
                Spacer(minLength: 0)
            }.padding(.bottom, 90)
                .padding(.top, 16)
            
            
            if showExpandedBlackScreen {
            } else if !showMenu {
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.black)
                    .frame(height: UIScreen.main.bounds.height / 8)
                    .offset(y: showMenu ? UIScreen.main.bounds.height : 370)
                    .overlay(
                        Text("  🫧  💫  👥            🍾  🥂  🎊  ")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .offset(y: showMenu ? UIScreen.main.bounds.height : 360)
                    )
                    .animation(.easeOut(duration: 1), value: showMenu)
                    .onTapGesture {
                        withAnimation {
                            showExpandedBlackScreen = true
                            showEmojis = false
                        }
                    }
            }
            
            
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
                }.padding(.horizontal, 0)
            }.ignoresSafeArea(.all)
            
            SideMenu2(showMenu: $showMenu, isSwitchOn: $isSwitchOn, namespace: animationNamespace)
                .animation(.easeInOut, value: showMenu)
                .offset(x: showMenu ? 0 : UIScreen.main.bounds.width)
        }
        .onTapGesture {
            withAnimation {
                if showExpandedBlackScreen {
                    showExpandedBlackScreen = false
                    showEmojis = true //ui change
                }
                if showMenu{
                    showMenu = false
                }
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
            }.frame(maxWidth: 250)
                .padding(.top, 10)
            TabView(selection: $selectedTab) {
                FriendsView2().tag(0)
                EventsView2().tag(1)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .frame(height: 650)
        .background(Color.black)
        .cornerRadius(30)
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
        ).onTapGesture {}
    }
    var expandedBlackScreenView: some View {
        
        VStack {
            HStack(spacing: 20) {
                Text("Friends").font(.system(size: 22, weight: selectedTab == 0 ? .bold : .regular)).foregroundColor(selectedTab == 0 ? .white : .gray).padding().onTapGesture {
                    withAnimation {
                        selectedTab = 0
                    }
                }
                Spacer()
                Text("Events").font(.system(size: 22, weight: selectedTab == 1 ? .bold : .regular)).foregroundColor(selectedTab == 1 ? .white : .gray).padding().onTapGesture {
                    withAnimation {
                        selectedTab = 1
                    }
                }
            }.padding(.horizontal, 60)
            TabView(selection: $selectedTab) {
                FriendsView2().tag(0)
                EventsView2().tag(1)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 3 / 4).background(Color.black).cornerRadius(50).transition(.move(edge: .bottom)).gesture(
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
        ).onTapGesture {}
    }
    
    var toggleSection2: some View {
        HStack(spacing: 10) {
            VStack(alignment: .trailing, spacing: 0) {
                Text("All")
                    .font(.system(size: 13).bold())
                    .foregroundColor(isForYouSelected ? .white : .gray)
                Spacer(minLength: 0)
                Text("For You")
                    .font(.system(size: 13).bold())
                    .foregroundColor(isForYouSelected ? .gray : .white)
            }.shadow(color: .black.opacity(1), radius: 20, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                .padding(.vertical, 12)
            
            Button(action: {
                withAnimation {
                    isForYouSelected.toggle()
                }
            }, label: {
                ZStack {
                    Rectangle()
                        .background(Material.regular)
                        .cornerRadius(50)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44 - 3 * 2, height: 44 - 3 * 2)
                        .offset(x: 0, y: isForYouSelected ?  -23 : 23)
                }
            }).frame(width: 44)
                .buttonStyle(NilButtonStyle())
        }.frame(height: 90)
    }
    
    var circleButton2: some View {
        Button(action: {
            withAnimation {
                showMenu.toggle()
            }
        }) {
            Circle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
                .matchedGeometryEffect(id: "circle", in: animationNamespace)
        }
    }
}

struct FriendsView2: View {
    var body: some View {
        VStack {
            Spacer()
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Friends")
                }.font(.system(size: 17, weight: .bold))
                    .frame(width: 200, height: 54)
                    .foregroundColor(.black).background(Color.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct EventsView2: View {
    var body: some View {
        VStack {
            Spacer()
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Events")
                }.font(.system(size: 17, weight: .bold))
                    .frame(width: 200, height: 54)
                    .foregroundColor(.black).background(Color.white)
                    .cornerRadius(10)
            }
        }
    }
}

import SwiftUI

struct SideMenu2: View {
    @Binding var showMenu: Bool
    @Binding var isSwitchOn: Bool
    
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            // Semi-transparent background with tap gesture to hide the menu
            if showMenu {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.05)) {
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
                    }
                    .frame(width: 385, height: 450)
                    .background(Color.black)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .matchedGeometryEffect(id: "circle", in: namespace)
                    // Empty gesture to 'capture' taps without triggering the background's gesture
                    .onTapGesture {}
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .leading))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    var profileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 25) {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 75, height: 75)
                    .overlay(
                        Button(action: {}, label: {
                            Text("Change")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                                .padding(8)
                                .padding(.horizontal, 3)
                                .background(Color.white)
                                .cornerRadius(50)
                        })
                        .offset(x: 0, y: 27)
                    )

                VStack(alignment: .leading) {
                    Text("username")
                        .font(.system(size: 20).bold())
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    Text("near this location")
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
                .font(.system(size: 17).bold())
                .foregroundColor(.white)
            Spacer()
            ZStack {
                Button(action: {
                    withAnimation {
                        isSwitchOn.toggle()
                    }
                }) {
                    Circle().fill(Color.white).frame(width: 35, height: 35)
                }
                .offset(x: isSwitchOn ? -30 : 30)

                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 100, height: 40)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(50)
                    .overlay(
                        HStack {
                            Text("On")
                                .font(.system(size: 13).bold())
                                .foregroundColor(isSwitchOn ? .white : .gray)
                                .offset(x: -13)
                            Text("Off")
                                .font(.system(size: 13).bold())
                                .foregroundColor(isSwitchOn ? .gray : .white)
                                .offset(x: 13)
                        }
                        .scaleEffect(0.75)
                        .offset(y: 20),
                        alignment: .bottom
                    )
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
            Spacer()
            Button("Sign Out") {
                // Handle sign out logic here
            }
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal, 5)
            .background(Color.black)
            .cornerRadius(50)
        }.frame(maxWidth: .infinity)
    }
}
struct MainPage2_Previews: PreviewProvider {
    static var previews: some View {
        //        ZStack {
        //            Rectangle()
        //                .background(Color.white)
        //            SideMenu(showMenu: .constant(true), isSwitchOn: .constant(false))
        //        }
        MainPage2()
    }
}
