//
//  SetTimeRS.swift
//  spark
//
//  Created by Kabir Borle on 2/27/24.
//

import SwiftUI
struct SetTime: View {
    @ObservedObject var viewModel: EventDateTimeViewModel
    @State private var endDate: Date = Date().addingTimeInterval(3 * 3600) // Default to 3 hours later
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                // Central White Rectangle
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(width: 350, height: 300)
                    .overlay(
                        VStack(spacing: 20) {
                            // Start Date Picker
                            DatePicker(
                                "Start:",
                                selection: $viewModel.startTime,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(DefaultDatePickerStyle()) // Default style for compact appearance
                            .padding()
                            // End Date Picker
                            DatePicker(
                                "End:",
                                selection: $viewModel.endTime,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(DefaultDatePickerStyle()) // Default style for compact appearance
                            .padding()
                        }
                    )
                // Set Time Button
                Button(action: {
                    viewModel.timeHasBeenSet = true
                        viewModel.isShowingSetTimeView = false
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .frame(width: 100, height: 50)
                        Text("Set Time")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}
struct SetTime_Previews: PreviewProvider {
    static var previews: some View {
        SetTime(viewModel: EventDateTimeViewModel())
    }
}


