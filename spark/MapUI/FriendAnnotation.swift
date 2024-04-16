//
//  FriendAnnotation.swift
//  spark
//
//  Created by Kabir Borle on 4/14/24.
//

import SwiftUI
import MapKit

class FriendAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var nearbyPlace: String?
    var userName: String?
    var locationLastUpdated: Date?
    var bitmojiUrl: String?
    
    

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, nearbyPlace: String?, userName: String?, locationLastUpdated: Date?, bitmojiUrl: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.nearbyPlace = nearbyPlace
        self.userName = userName
        self.locationLastUpdated = locationLastUpdated
        self.bitmojiUrl = bitmojiUrl
    }
}
