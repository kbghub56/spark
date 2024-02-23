//
//  UserModel.swift
//  spark
//
//  Created by Kabir Borle on 2/18/24.
//

import SwiftUI

struct User: Codable {
    var userName: String?
    var email: String
    var uniqueUserID: String
    var friends: [String]

    enum CodingKeys: String, CodingKey {
        case userName
        case email
        case uniqueUserID
        case friends
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userName = try container.decodeIfPresent(String.self, forKey: .userName)
        email = try container.decode(String.self, forKey: .email)
        uniqueUserID = try container.decode(String.self, forKey: .uniqueUserID)
        friends = try container.decode([String].self, forKey: .friends)
    }

}
