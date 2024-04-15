//
//  PopupManager.swift
//  spark
//
//  Created by Kabir Borle on 4/14/24.
//

import SwiftUI

class PopupManager: ObservableObject {
    @Published var selectedEvent: Event?
    @Published var isPopupVisible: Bool = false
}
