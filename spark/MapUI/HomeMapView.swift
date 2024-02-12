//
//  HomeMapView.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//

import SwiftUI

struct HomeMapView: View{
    var body: some View{
        MapViewRepresentable()
            .ignoresSafeArea()
    }
}

struct HomeMapView_Previews: PreviewProvider{
    static var previews: some View{
        HomeMapView()
    }
}
