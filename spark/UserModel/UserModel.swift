//
//  UserModel.swift
//  spark
//
//  Created by Kabir Borle on 2/18/24.
//

import SwiftUI

struct User: Identifiable, Codable {
    let id: String // Firestore document ID, which is the user's UID
    let userName: String
    let email: String
}

