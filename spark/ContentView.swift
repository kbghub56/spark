//
//  ContentView.swift
//  spark
//
//  Created by Kabir Borle on 2/9/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: EventInputView()) {
                    Text("Add New Event")
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
