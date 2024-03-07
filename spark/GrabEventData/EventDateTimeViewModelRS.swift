//
//  EventDateTimeViewModelRS.swift
//  spark
//
//  Created by Kabir Borle on 2/27/24.
//

import SwiftUI
class EventDateTimeViewModel: ObservableObject {
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var isShowingSetTimeView: Bool = false
    @Published var timeHasBeenSet: Bool = false // Add this line
}

