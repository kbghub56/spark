//
//  ContentView.swift
//  spark
//
//  Created by Kabir Borle on 2/9/24.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isUserAuthenticated {
            HomeMapView()
        } else {
            LoginView().environmentObject(authViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


