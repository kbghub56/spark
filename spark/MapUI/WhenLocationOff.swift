//
//  WhenLocationOff.swift
//  spark
//
//  Created by Kabir Borle on 3/6/24.
//

import SwiftUI
import MapKit
struct WhenLocationOff: View {
    private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    var body: some View {
        ZStack {
            Map(coordinateRegion: .constant(region), interactionModes: [])
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, .dark)
                .disabled(true) // Disable interaction with the map
            // White rectangle with the lock icon and text
            ZStack {
                RoundedRectangle(cornerRadius: 50) // 50 degree rounded edges
                    .fill(Color.white)
                    .frame(width: 350, height: 350)
                    .overlay(
                        VStack {
                            Text("Features remain locked until location enabled")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center) // Center-align the text
                                .padding(.bottom, 20)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.black)
                            Button(action: {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString),
                                   UIApplication.shared.canOpenURL(appSettings) {
                                    UIApplication.shared.open(appSettings)
                                }
                            })  {
                                Text("Enable location sharing")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding() // Add padding around the text for the light blue box
                                    .background(Color.blue.opacity(0.3)) // Light blue box
                                    .cornerRadius(10) // Rounded edges for the light blue box
                            }
                            .padding(.top, 20)
                        }
                    )
            }
        }
    }
}
struct WhenLocationOff_Previews: PreviewProvider {
    static var previews: some View {
        WhenLocationOff()
    }
}

