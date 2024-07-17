//
//  UserModel.swift
//  spark
//
//  Created by Kabir Borle on 2/18/24.
//

import SwiftUI
import Foundation

struct User: Codable {
    var docID: String?  // Optional property for the Firebase document ID
    var userName: String
    var email: String
    var uniqueUserID: String
    var friends: [String]
    var latitude: Double?
    var longitude: Double?
    var locationLastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case docID
        case userName
        case email
        case uniqueUserID
        case friends
        case latitude
        case longitude
        case locationLastUpdated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        docID = try container.decodeIfPresent(String.self, forKey: .docID)  // Decode the docID if present
        userName = try container.decode(String.self, forKey: .userName)
        email = try container.decode(String.self, forKey: .email)
        uniqueUserID = try container.decode(String.self, forKey: .uniqueUserID)
        friends = try container.decode([String].self, forKey: .friends)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        locationLastUpdated = try container.decodeIfPresent(Date.self, forKey: .locationLastUpdated)
    }

    // Implement the encode(to encoder: Encoder) method to include docID when encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(docID, forKey: .docID)
        try container.encodeIfPresent(userName, forKey: .userName)
        try container.encode(email, forKey: .email)
        try container.encode(uniqueUserID, forKey: .uniqueUserID)
        try container.encode(friends, forKey: .friends)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(locationLastUpdated, forKey: .locationLastUpdated)
    }
    
    func isFullyLoaded() -> Bool {
            // Check if all necessary properties are non-nil and non-empty
            return !uniqueUserID.isEmpty && !userName.isEmpty // Add more checks as needed
        }

    // Add any other initializers if necessary
}
