//
//  FollowReq2Test.swift
//  spark
//
//  Created by Kabir Borle on 4/9/24.
//

import SwiftUI
import MapKit

struct FriendRequest2: View {
    private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        ZStack {
            Map(coordinateRegion: .constant(region), interactionModes: [])
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, .dark)
                .disabled(true)
            ZStack {
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.white)
                    .frame(width: 350, height: 350)
                    .overlay(
                        VStack(spacing:40){
                            Text("New Friends?")
                                .font(.title)                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            Text("Name")
                                .font(.largeTitle)
                                .bold()
                                

                            HStack(spacing: 45) {
                                Button("Accept") {
                                }
                                .foregroundColor(.white)
                                .font(.system(size: 22, weight: .bold))
                                .padding()
                                .scaleEffect(0.8)
                                .background(Color.black)
                                .cornerRadius(10)

                                Button("Deny") {
                                }
                                .foregroundColor(.white)
                                .scaleEffect(0.8)
                                .font(.system(size: 22, weight: .bold))
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                            }
                        }
                    )
            }
        }
    }
}

struct FriendRequest2_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequest2()
    }
}
