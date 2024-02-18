//
//  UserModel.swift
//  spark
//
//  Created by Kabir Borle on 2/18/24.
//

import SwiftUI

struct User: Identifiable, Codable {
    var id: String // Use 'var' to make it mutable
    var userName: String
    var email: String

    // Optionally, add an initializer if needed
    init(id: String, userName: String, email: String) {
        self.id = id
        self.userName = userName
        self.email = email
    }
}
