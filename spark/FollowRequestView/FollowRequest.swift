//
//  FollowRequest.swift
//  spark
//
//  Created by Kabir Borle on 2/22/24.
//

import SwiftUI

struct FollowRequest: Identifiable {
    let id: String
    let fromUserID: String
    let toUserID: String
    var status: String  // e.g., "pending", "approved", "rejected"
}
