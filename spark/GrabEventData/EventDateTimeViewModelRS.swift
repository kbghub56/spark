//
//  EventDateTimeViewModelRS.swift
//  spark
//
//  Created by Kabir Borle on 2/27/24.
//

import SwiftUI

class EventDateTimeViewModel: ObservableObject {
    @Published var startTime: Date = Date() {
        didSet {
            adjustEndTimeIfNeeded()
        }
    }
    @Published var endTime: Date = Date().addingTimeInterval(3600) {
        didSet {
            adjustEndTimeIfNeeded()
        }
    }
    @Published var isShowingSetTimeView: Bool = false
    @Published var timeHasBeenSet: Bool = false

    private func adjustEndTimeIfNeeded() {
        // If the end time is before the start time, adjust the end time to the next day
        if endTime < startTime {
            endTime = Calendar.current.date(byAdding: .day, value: 1, to: endTime) ?? endTime
        }
    }
}


