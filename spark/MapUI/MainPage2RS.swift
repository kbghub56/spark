//
//  MainPage2RS.swift
//  spark
//
//  Created by Kabir Borle on 4/2/24.
//

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
    @State private var showEmojis = true //ui change
    
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $trackingMode)
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, .dark)
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
                Spacer(minLength: 0)
            }.padding(.bottom, 90)
                .padding(.top, 16)
            
            
            if showExpandedBlackScreen {
                //expandedBlackScreenView
            } else if !showMenu { // Check if the SideMenu is not shown
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
                    .animation(.easeOut(duration: 1), value: showMenu) // anichange
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
                    //  mapModal
                }.padding(.horizontal, 0)
            }.ignoresSafeArea(.all)
            
            SideMenu2(showMenu: $showMenu, isSwitchOn: $isSwitchOn)
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
            //            Image(systemName: "chevron.compact.down")
            //                .font(.system(size: 30, weight: .medium, design: .default))
            //                .foregroundColor(.gray)
            //                .padding(.top, 16)
            HStack {
                Text("Friends")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(selectedTab == 0 ? .white : .gray)
                    .onTapGesture {
                        withAnimation {
                            selectedTab = 0
                        }
                    }
                Spacer()
                Text("Events")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(selectedTab == 1 ? .white : .gray)
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
        .background(Material.thick)
        .cornerRadius(30)
        .transition(.move(edge: .bottom)).gesture(
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
    
    var toggleSection: some View {
        HStack(spacing: 10) {
            VStack(alignment: .trailing, spacing: 0) {
                Text("All")
                    .font(.system(size: 13).bold())
                    .foregroundColor(isForYouSelected ? .white : .gray)
                Spacer(minLength: 0)
                Text("For You")
                    .font(.system(size: 13).bold())
                    .foregroundColor(isForYouSelected ? .gray : .white)
            }.shadow(color: .black.opacity(1), radius: 20, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/) // TODO: Add shadows
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
    
    var circleButton: some View {
        Button(action: {
            withAnimation {
                showMenu = true
            }
        }) {
            Circle().fill(Color.white).frame(width: 50, height: 50)
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

struct SideMenu2: View {
    @Binding var showMenu: Bool
    @Binding var isSwitchOn: Bool
    
    var body: some View {
        ZStack() {
            Rectangle()
                .fill(Color.clear)
                .onTapGesture {
                    withAnimation {
                        showMenu = false
                    }
                }
            HStack(spacing: 0) {
                Spacer()
                VStack(alignment: .leading) {
                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 75, height: 75)
                            .padding(.top, 20)
                            .overlay(
                                alignment: .bottom) {
                                    Button(action: {
                                        
                                    }, label: {
                                        Text("Change")
                                            .font(.system(size: 13))
                                    }).foregroundColor(.black)
                                        .padding(8)
                                        .padding(.horizontal, 3)
                                        .background(Color.white)
                                        .cornerRadius(50)
                                        .offset(x: 0, y: 10.0)
                                }
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
                    HStack(alignment: .center) {
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
                            }.offset(x: isSwitchOn ? -30 : 30)
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 100, height: 40)
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(50)
                                .overlay(
                                    HStack{
                                        Text("On")
                                            .font(.system(size: 13).bold())
                                            .foregroundColor(isSwitchOn ? .white : .gray)
                                            .offset(x: -13)
                                        Text("Off")
                                            .font(.system(size: 13).bold())
                                            .foregroundColor(isSwitchOn ? .gray : .white)
                                            .offset(x: 13)
                                    }.scaleEffect(0.75)
                                        .offset(y: 20),
                                    alignment: .bottom
                                )
                        }
                    }
                    Text("Your Collages 📷:")
                        .font(.system(size: 20).bold())
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .padding(.bottom, 10)
                    
                    HStack {
                        Spacer()
                        VStack {
                            HStack {
                                Image("PNG image 1")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(15)
                                    .blur(radius: 1.5)
                                Image("PNG image 2")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(15)
                                    .blur(radius: 1.5)
                            }
                            HStack {
                                Image("PNG image 3")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(15)
                                    .blur(radius: 1.5)
                                Image("PNG image")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(15)
                                    .blur(radius: 1.5)
                            }
                        }.overlay(
                            VStack {
                                Image(systemName: "lock.fill").font(.title).foregroundColor(.white)
                                Text("coming soon ...").font(.subheadline).foregroundColor(.white)
                            }
                        )
                        Spacer()
                    }
                    Spacer()
                    Button(
                        action: {
                            
                        }, label: {
                            Text("Sign Out")
                        }
                    ).font(.system(size: 17).bold())
                        .foregroundColor(.black)
                        .padding(10)
                        .padding(.horizontal, 5)
                        .background(Color.white)
                        .cornerRadius(50)
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black)
                        .edgesIgnoringSafeArea(.all)
                )
                .frame(width: UIScreen.main.bounds.width * 3 / 4)
                    
            }.onTapGesture {
                
            }
        }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
//        ZStack {
//            Rectangle()
//                .background(Color.white)
//            SideMenu(showMenu: .constant(true), isSwitchOn: .constant(false))
//        }
        MainPage2()
    }
}
