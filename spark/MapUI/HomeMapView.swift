//
//  HomeMapView.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//

import SwiftUI

struct HomeMapView: View {
    @StateObject var eventsViewModel = EventsViewModel()
    @State private var showingEventInputView = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var logoutButton: some View {
        Button("Log Out") {
            authViewModel.logOut()
        }
    }
    
    var body: some View {
        NavigationView {
            MapViewRepresentable(eventsViewModel: eventsViewModel)
                .ignoresSafeArea()
                .navigationBarTitle("Spark", displayMode: .inline)
                .navigationBarItems(trailing: HStack {
                    // Add event button (if you have one)
                    Button(action: {
                        showingEventInputView = true
                    }) {
                        Image(systemName: "plus")
                    }
                    // Sign out button
                    Button(action: {
                        authViewModel.logOut()
                    }) {
                        Image(systemName: "arrow.backward.circle")
                            .imageScale(.large)
                    }
                })
                .sheet(isPresented: $showingEventInputView) {
                    EventInputView()
                }
        }
    }
    
}

struct HomeMapView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMapView()
    }
}
