//
//  UserModel.swift
//  spark
//
//  Created by Kabir Borle on 2/18/24.
//

import SwiftUI

import Foundation

struct User: Codable {
    var userName: String?
    var email: String
    var uniqueUserID: String
    var friends: [String]
    var latitude: Double?
    var longitude: Double?
    var locationLastUpdated: Date?

    enum CodingKeys: String, CodingKey {
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
        userName = try container.decodeIfPresent(String.self, forKey: .userName)
        email = try container.decode(String.self, forKey: .email)
        uniqueUserID = try container.decode(String.self, forKey: .uniqueUserID)
        friends = try container.decode([String].self, forKey: .friends)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        locationLastUpdated = try container.decodeIfPresent(Date.self, forKey: .locationLastUpdated)
    }

    // Implement the encode(to encoder: Encoder) throws method if necessary
}
